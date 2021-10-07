#/usr/bin/env bash

source hack/handy.sh
if [[ $CI == "true" ]]
then
    FLUX=/tmp/flux
else
    FLUX=$(which flux)
fi

echo -e -n "\rInstalling 23KE"
if ! kubectl -n flux-system get secret target-gardencluster-kubeconfig > /tmp/stdout 2> /tmp/stderr
then
	kubectl -n flux-system create secret generic target-gardencluster-kubeconfig --from-literal=value="$(cat hack/secrets/shoot-kubeconfig.yaml)" > /tmp/stdout 2> /tmp/stderr || { echo -e "\rError while creating target-gardencluster-kubeconfig secret ❌"; echo "STDOUT":; cat /tmp/stdout; echo "STDERR:"; cat /tmp/stderr; exit 1; }
fi
echo -n "."

# Templating 23ke-env-substitutions.yaml
yq eval '.stringData.BASE_DOMAIN = env(SHOOT) + ".23t-test.okeanos.dev"' env-template/config/23ke-env-substitutions.yaml > hack/23ke-env-substitutions.yaml
yq eval '.stringData.DASHBOARD_CLIENTSECRET = env(DASHBOARD_CLIENTSECRET)' -i hack/23ke-env-substitutions.yaml
yq eval '.stringData.DASHBOARD_SESSIONSECRET = env(DASHBOARD_SESSIONSECRET)' -i hack/23ke-env-substitutions.yaml
yq eval '.stringData.KUBEAPISERVER_BASICAUTHPASSWORD = env(KUBEAPISERVER_BASICAUTHPASSWORD)' -i hack/23ke-env-substitutions.yaml
kubectl apply -f hack/23ke-env-substitutions.yaml > /tmp/stdout 2> /tmp/stderr || { echo -e "\rError while applying 23ke-env-substitutions secret ❌"; echo "STDOUT":; cat /tmp/stdout; echo "STDERR:"; cat /tmp/stderr; exit 1; }
rm hack/23ke-env-substitutions.yaml
if ! kubectl -n flux-system get secret minio-local > /tmp/stdout 2> /tmp/stderr
then
	kubectl create secret generic -n flux-system minio-local --from-literal=accesskey=minio --from-literal=secretkey=$MINIO_PW > /tmp/stdout 2> /tmp/stderr || { echo -e "\rError while Creating secret. ❌" ; echo "STDOUT":; cat /tmp/stdout; echo "STDERR:"; cat /tmp/stderr; exit 1; }
fi
echo -n "."
$FLUX create source bucket $BUCKET --endpoint=$MINIO_HOSTNAME --bucket-name=$BUCKET --secret-ref=minio-local > /tmp/stdout 2> /tmp/stderr || { echo -e "\rError while creating flux 23ke bucket source ❌"; echo "STDOUT":; cat /tmp/stdout; echo "STDERR:"; cat /tmp/stderr; exit 1; }
echo -n "."
$FLUX create source bucket 23ke-config --endpoint=$MINIO_HOSTNAME --bucket-name=config --secret-ref=minio-local > /tmp/stdout 2> /tmp/stderr || { echo -e "\rError while creating flux 23ke-config bucket source ❌"; echo "STDOUT":; cat /tmp/stdout; echo "STDERR:"; cat /tmp/stderr; exit 1; }
echo -n "."
kubectl apply -f hack/kustomizations > /tmp/stdout 2> /tmp/stderr || { echo -e "\rError while applying flux-kustomizations  ❌"; echo "STDOUT":; cat /tmp/stdout; echo "STDERR:"; cat /tmp/stderr; exit 1; }
echo -n "."

echo -e -n "\r                          "
echo -e -n "\rWaiting for ks"
kubectl wait kustomization 23ke-base -n flux-system --for=condition=ready --timeout=10m > /tmp/stdout 2> /tmp/stderr || { echo -e "\rError while waiting for flux-kustomization 23ke-base ❌"; echo "STDOUT":; cat /tmp/stdout; echo "STDERR:"; cat /tmp/stderr; exit 1; }
echo -n "."
kubectl wait kustomization 23ke-env -n flux-system --for=condition=ready --timeout=10m > /tmp/stdout 2> /tmp/stderr || { echo -e "\rError while waiting for flux-kustomization 23ke-env ❌"; echo "STDOUT":; cat /tmp/stdout; echo "STDERR:"; cat /tmp/stderr; exit 1; }
echo -n "."
kubectl wait kustomization -A --all --for=condition=ready --timeout=10m > /tmp/stdout 2> /tmp/stderr || { echo -e "\rError while waiting for flux-kustomizations ❌"; echo "STDOUT":; cat /tmp/stdout; echo "STDERR:"; cat /tmp/stderr; exit 1; }
echo -e -n "\rWaiting for helmreleases"
kubectl wait helmrelease -A --all --for=condition=ready --timeout=20m > /tmp/stdout 2> /tmp/stderr || { echo -e "\rError while waiting for helmreleases ❌"; echo "STDOUT":; cat /tmp/stdout; echo "STDERR:"; cat /tmp/stderr; exit 1; }
# Extract apiserver-in-shoot-kubeconfig.yaml
kubectl get secrets -n garden garden-kubeconfig-for-admin -o go-template='{{.data.kubeconfig | base64decode }}' > hack/secrets/apiserver-in-shoot-kubeconfig.yaml 2> /tmp/stderr || { echo -e "\rError while extracting apiserver-in-shoot-kubeconfig ❌"; echo "STDERR:"; cat /tmp/stderr; exit 1; }
echo -n "."
echo -e "\r23KE Ready           ✅                  "