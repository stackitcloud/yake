# [gardener]
## ⚠️ Breaking Changes
* *[USER]* The `core.gardener.cloud/v1alpha1` API is deprecated and will be removed soon. The `core.gardener.cloud/v1beta1` API is already available since a very long time and should be used instead. ([gardener/gardener#7443](https://github.com/gardener/gardener/pull/7443), [@ary1992](https://github.com/ary1992))
* *[USER]* Support for shoot annotation `alpha.control-plane.shoot.gardener.cloud/high-availability` has been dropped. Existing shoot clusters have already been migrated to the respective `spec` fields since Gardener [v1.60.0](https://github.com/gardener/gardener/releases/tag/v1.60.0). Starting with this release, the annotation is not respected and the migration will not happen anymore. Please make sure to use `shoot.spec.controlPlane.highAvailability.failureTolerance: {node, zone}` instead. ([gardener/gardener#7493](https://github.com/gardener/gardener/pull/7493), [@timuthy](https://github.com/timuthy))
* *[OPERATOR]* Before upgrading to this Gardener version, `Seed`s using `.spec.dns.ingressDomain` must now finally be switched to using `.spec.ingress` and `.spec.dns.provider` (as changed with https://github.com/gardener/gardener/pull/3131 back in 2020). Please find more information about it [here](https://github.com/gardener/gardener/tree/master/docs/deployment/deploy_gardenlet_manually.md#kubernetes-cluster-that-should-be-registered-as-a-seed-cluster). The `.spec.dns.ingressDomain` field is deprecated since more than 2 years and will be removed in a future version. ([gardener/gardener#7515](https://github.com/gardener/gardener/pull/7515), [@rfranzke](https://github.com/rfranzke))
* *[DEPENDENCY]* Extensions which deploy components that need to be scraped by the Prometheis in the shoot namespaces need to adapt to the new `NetworkPolicy`s. For more information, read [this section](https://github.com/gardener/gardener/tree/master/docs/development/seed_network_policies.md#network-policies-for-logging--monitoring). ([gardener/gardener#7484](https://github.com/gardener/gardener/pull/7484), [@rfranzke](https://github.com/rfranzke))
* *[DEPENDENCY]* Extensions which deploy components to shoot namespaces need to adapt to the new `NetworkPolicy`s. Concretely, the following labels related to `NetworkPolicies` are deprecated and should be replaced: ([gardener/gardener#7515](https://github.com/gardener/gardener/pull/7515), [@rfranzke](https://github.com/rfranzke))
  * `networking.gardener.cloud/to-shoot-apiserver=allowed`, replace it with `networking.resources.gardener.cloud/to-kube-apiserver-tcp-443=allowed`.
  * `networking.gardener.cloud/from-shoot-apiserver=allowed`, replace it with the label `networking.resources.gardener.cloud/to-<service-name>-tcp-<container-port>=allowed` on `kube-apiserver` pods.
## ✨ New Features
* *[USER]* A taint is added to all `Node` objects on registration by the `kubelet`. Gardener removes the taint once all node-critical pods are ready. This makes sure that user workload is only scheduled to nodes where all node-critical components are ready. Please refer to the [documentation](https://github.com/gardener/gardener/blob/master/docs/usage/node-readiness.md) for more details. ([gardener/gardener#7406](https://github.com/gardener/gardener/pull/7406), [@timebertt](https://github.com/timebertt))
* *[DEVELOPER]* Now by default, Gardener performs health check for all the `ManagedResource`s with `.spec.class=nil` created in the shoot namespaces. Extensions using Gardener `v1.65.0` onwards can drop the health check for the MangedResource. ([gardener/gardener#7462](https://github.com/gardener/gardener/pull/7462), [@acumino](https://github.com/acumino))
* *[DEVELOPER]* Extensions can label node-critical pods that they manage with `node.gardener.cloud/critical-component=true` to ensure user workload is only scheduled to nodes where all node-critical components are ready. Please refer to the [documentation](https://github.com/gardener/gardener/blob/master/docs/usage/node-readiness.md) for more details. ([gardener/gardener#7406](https://github.com/gardener/gardener/pull/7406), [@timebertt](https://github.com/timebertt))
* *[DEPENDENCY]* The `goimports-reviser` is updated to a version that properly ignores generated files. ([gardener/gardener#7492](https://github.com/gardener/gardener/pull/7492), [@vpnachev](https://github.com/vpnachev))
## 🐛 Bug Fixes
* *[OPERATOR]* Fix a bug in the etcd deploy flow that erroneously unsets `etcd.Spec.Etcd.PeerUrlTls` in the ETCD CRs of high available shoots when marked for hibernation. ([gardener/gardener#7514](https://github.com/gardener/gardener/pull/7514), [@aaronfern](https://github.com/aaronfern))
  * Before this change, high availability clusters failed to be deleted while being hibernated.
* *[OPERATOR]* An issues has been fixed that caused outdated Envoy stats filters not being cleaned up in `Istio-Ingress` namespaces. ([gardener/gardener#7397](https://github.com/gardener/gardener/pull/7397), [@timuthy](https://github.com/timuthy))
* *[DEVELOPER]* The Gardener upgrade tests have been updated to use the previous minor version of Gardener instead of the latest release tag when the environment variable `GARDENER_PREVIOUS_RELEASE` is not specified. ([gardener/gardener#7491](https://github.com/gardener/gardener/pull/7491), [@seshachalam-yv](https://github.com/seshachalam-yv))
## 🏃 Others
* *[USER]* The `PodSecurity` kube-apiserver admission plugin config in the Shoot, if provided, is now validated. ([gardener/gardener#7472](https://github.com/gardener/gardener/pull/7472), [@shafeeqes](https://github.com/shafeeqes))
* *[OPERATOR]* Fluent-bit daemon set memory limit increased to 650MB and request to 200MB. ([gardener/gardener#7564](https://github.com/gardener/gardener/pull/7564), [@vlvasilev](https://github.com/vlvasilev))
* *[OPERATOR]* The `ExposureClass` and `ShootState` resources have been promoted to `v1beta1`. ([gardener/gardener#7443](https://github.com/gardener/gardener/pull/7443), [@ary1992](https://github.com/ary1992))
* *[OPERATOR]* Add response rewrite to dns-search-path-optimization, as some clients require matching hostnames in a DNS query and the answer. ([gardener/gardener#7478](https://github.com/gardener/gardener/pull/7478), [@axel7born](https://github.com/axel7born))
* *[OPERATOR]* `nginx-ingress-controller-seed` image is updated to `v1.6.4` for 1.23+ seeds and `v1.4.0` for 1.22.x seeds. ([gardener/gardener#7490](https://github.com/gardener/gardener/pull/7490), [@shafeeqes](https://github.com/shafeeqes))
* *[OPERATOR]* Remove limit defaults from helm charts for controlplane components ([gardener/gardener#7494](https://github.com/gardener/gardener/pull/7494), [@voelzmo](https://github.com/voelzmo))
* *[OPERATOR]* The resource-manager now recreates immutable Secrets/ConfigMaps on invalid update error. ([gardener/gardener#7516](https://github.com/gardener/gardener/pull/7516), [@shafeeqes](https://github.com/shafeeqes))
* *[OPERATOR]* Loki user tenant is removed. ([gardener/gardener#7523](https://github.com/gardener/gardener/pull/7523), [@vlvasilev](https://github.com/vlvasilev))
* *[OPERATOR]* An issue causing a nil pointer error in the `seed-lifecycle` controller is fixed. ([gardener/gardener#7539](https://github.com/gardener/gardener/pull/7539), [@acumino](https://github.com/acumino))
* *[DEVELOPER]* The Shoot creation integration test now saves the kubeconfig obtained from the `shoot/adminkubeconfig` to `$TM_KUBECONFIG_PATH/shoot.config`. Previously, it was saving the static token kubeconfig. ([gardener/gardener#7495](https://github.com/gardener/gardener/pull/7495), [@ialidzhikov](https://github.com/ialidzhikov))
* *[DEVELOPER]* `golangci-lint` has been updated to v1.51.2. ([gardener/gardener#7537](https://github.com/gardener/gardener/pull/7537), [@vpnachev](https://github.com/vpnachev))
* *[DEVELOPER]* Update to Go `1.19.6`. ([gardener/gardener#7542](https://github.com/gardener/gardener/pull/7542), [@oliver-goetz](https://github.com/oliver-goetz))
* *[DEPENDENCY]* `hack/format.sh` now can run `goimports-reviser` with custom options set via the environment variable `GOIMPORTS_REVISER_OPTIONS`. ([gardener/gardener#7502](https://github.com/gardener/gardener/pull/7502), [@vpnachev](https://github.com/vpnachev))
# [etcd-backup-restore]
## 🐛 Bug Fixes
* *[OPERATOR]* Fixes bug of false wrong annotation added to etcd-member lease of TLS not enabled. ([gardener/etcd-backup-restore#564](https://github.com/gardener/etcd-backup-restore/pull/564), [@ishan16696](https://github.com/ishan16696))
## 🏃 Others
* *[USER]* Better error message if setting in etcd config is missing ([gardener/etcd-backup-restore#582](https://github.com/gardener/etcd-backup-restore/pull/582), [@mxmxchere](https://github.com/mxmxchere))
* *[USER]* Update alpine base image to `3.15.7`. ([gardener/etcd-backup-restore#590](https://github.com/gardener/etcd-backup-restore/pull/590), [@shreyas-s-rao](https://github.com/shreyas-s-rao))
* *[OPERATOR]* making chunk-size configurable by introducing flag: `--min-chunk-size` (default value 5MB), it will be helpful in fine tuning the multi-part chunk upload size for different storage provider. ([gardener/etcd-backup-restore#545](https://github.com/gardener/etcd-backup-restore/pull/545), [@louisportay](https://github.com/louisportay))
* *[OPERATOR]* Removed owner checks that were used to restart the `etcd` process that runs in the source `Seed` cluster during "bad case" control plane migration. ([gardener/etcd-backup-restore#555](https://github.com/gardener/etcd-backup-restore/pull/555), [@plkokanov](https://github.com/plkokanov))
* *[OPERATOR]* Enhances the decision to take full snapshot during startup of etcd-backup-restore to avoid missing of any full-snapshot. ([gardener/etcd-backup-restore#574](https://github.com/gardener/etcd-backup-restore/pull/574), [@ishan16696](https://github.com/ishan16696))
## 📰 Noteworthy
* *[OPERATOR]* Added support for Application credentials to authenticate Openstack client for Openstack backup buckets. ([gardener/etcd-backup-restore#580](https://github.com/gardener/etcd-backup-restore/pull/580), [@ishan16696](https://github.com/ishan16696))
* *[OPERATOR]* Update golang version for Docker image build to `v1.19.3`. ([gardener/etcd-backup-restore#561](https://github.com/gardener/etcd-backup-restore/pull/561), [@ishan16696](https://github.com/ishan16696))
* *[DEVELOPER]* Update golang build version to `1.19.5`. ([gardener/etcd-backup-restore#590](https://github.com/gardener/etcd-backup-restore/pull/590), [@shreyas-s-rao](https://github.com/shreyas-s-rao))
* *[DEVELOPER]* Update golang version for dependency vendoring to `v1.19`. ([gardener/etcd-backup-restore#561](https://github.com/gardener/etcd-backup-restore/pull/561), [@ishan16696](https://github.com/ishan16696))
# [etcd-druid]
## ✨ New Features
* *[OPERATOR]* Enhance `kubectl` printer columns for `Etcd` resource. ([gardener/etcd-druid#490](https://github.com/gardener/etcd-druid/pull/490), [@shreyas-s-rao](https://github.com/shreyas-s-rao))
## 🏃 Others
* *[USER]* Explicitly set logging options to use JSON logging and ISO8601 timestamp format. ([gardener/etcd-druid#525](https://github.com/gardener/etcd-druid/pull/525), [@shreyas-s-rao](https://github.com/shreyas-s-rao))
* *[OPERATOR]* `--etcd-process-name` has been deprecated and is now not added to the statefulset ([gardener/etcd-druid#514](https://github.com/gardener/etcd-druid/pull/514), [@aaronfern](https://github.com/aaronfern))
* *[OPERATOR]* The Etcd resource now allows specify etcd client Service labels via the `spec.etcd.clientService.labels` field. ([gardener/etcd-druid#485](https://github.com/gardener/etcd-druid/pull/485), [@ialidzhikov](https://github.com/ialidzhikov))
* *[OPERATOR]* Removed ability to set owner checks that were used to restart the `etcd` process that runs in the source `Seed` cluster during "bad case" control plane migration. ([gardener/etcd-druid#461](https://github.com/gardener/etcd-druid/pull/461), [@plkokanov](https://github.com/plkokanov))
* *[DEVELOPER]* Update golang build version to `v1.19.4`. ([gardener/etcd-druid#495](https://github.com/gardener/etcd-druid/pull/495), [@shreyas-s-rao](https://github.com/shreyas-s-rao))
* *[DEPENDENCY]* Dependency `github.com/gardener/gardener` is updated `v1.36.0` -> `v1.57.1` ([gardener/etcd-druid#450](https://github.com/gardener/etcd-druid/pull/450), [@AleksandarSavchev](https://github.com/AleksandarSavchev))
* *[DEPENDENCY]* Dependency `github.com/onsi/ginkgo` is upgraded to `github.com/onsi/ginkgo/v2` ([gardener/etcd-druid#450](https://github.com/gardener/etcd-druid/pull/450), [@AleksandarSavchev](https://github.com/AleksandarSavchev))
* *[DEPENDENCY]* The dependency of `sigs.k8s.io/controller-runtime/pkg/envtest/printer` package in `etcd-druid` is removed. ([gardener/etcd-druid#493](https://github.com/gardener/etcd-druid/pull/493), [@shafeeqes](https://github.com/shafeeqes))
# [logging]
## 🏃 Others
* *[OPERATOR]* Loki label `docker_id` is replaced by `container_id`. ([gardener/logging#172](https://github.com/gardener/logging/pull/172), [@vlvasilev](https://github.com/vlvasilev))
* *[OPERATOR]* Logging Gardener-specific multi-tenancy can be switched off by `EnableMultiTenancy`. ([gardener/logging#172](https://github.com/gardener/logging/pull/172), [@vlvasilev](https://github.com/vlvasilev))