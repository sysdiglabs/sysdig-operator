IMAGE = sysdiglabs/sysdig-operator
# Use same version than helm chart
VERSION = 1.4.0

CERTIFIED_IMAGE = registry.connect.redhat.com/sysdig/sysdig-operator
# Eventually it will use the same tag than VERSION
CERTIFIED_IMAGE_VERSION = 1.4.0-e5365ddec6d6

.PHONY: build bundle.yaml

build:
	helm fetch stable/sysdig --version $(VERSION) --untar --untardir helm-charts/
	operator-sdk build $(IMAGE):$(VERSION)
	rm -fr helm-charts/sysdig

push:
	docker push $(IMAGE):$(VERSION)

bundle.yaml:
	cat deploy/crds/sysdig_v1alpha1_sysdig_crd.yaml > bundle.yaml
	echo '---' >> bundle.yaml
	sed -i 's|REPLACE_IMAGE|docker.io/$(IMAGE):$(VERSION)|g' deploy/operator.yaml
	cat deploy/service_account.yaml >> bundle.yaml
	echo '---' >> bundle.yaml
	cat deploy/role_binding.yaml >> bundle.yaml
	echo '---' >> bundle.yaml
	cat deploy/operator.yaml >> bundle.yaml

e2e: bundle.yaml
	kubectl apply -f bundle.yaml
	sed -i 's|ACCESS_KEY|${SYSDIG_AGENT_ACCESS_KEY}|g' deploy/crds/sysdig_v1alpha1_sysdig_cr.yaml
	kubectl apply -f deploy/crds/sysdig_v1alpha1_sysdig_cr.yaml

e2e-clean: bundle.yaml
	kubectl delete -f deploy/crds/sysdig_v1alpha1_sysdig_cr.yaml
	kubectl delete -f bundle.yaml

package-redhat:
	cp deploy/crds/sysdig_v1alpha1_sysdig_crd.yaml redhat-certification/sysdig.crd.yaml
	cp redhat-certification/sysdig-operator.vX.X.X.clusterserviceversion.yaml redhat-certification/sysdig-operator.v${VERSION}.clusterserviceversion.yaml
	\
	sed -i 's|REPLACE_VERSION|${VERSION}|g' redhat-certification/sysdig-operator.v${VERSION}.clusterserviceversion.yaml
	sed -i 's|REPLACE_IMAGE|${CERTIFIED_IMAGE}|g' redhat-certification/sysdig-operator.v${VERSION}.clusterserviceversion.yaml
	sed -i 's|REPLACE_CERTIFIED_VERSION|${CERTIFIED_IMAGE_VERSION}|g' redhat-certification/sysdig-operator.v${VERSION}.clusterserviceversion.yaml
	sed -i 's|REPLACE_VERSION|${VERSION}|g' redhat-certification/sysdig.package.yaml
	\
	zip -j redhat-certification-metadata-${VERSION}.zip \
		redhat-certification/sysdig-operator.v${VERSION}.clusterserviceversion.yaml \
		redhat-certification/sysdig.crd.yaml \
		redhat-certification/sysdig.package.yaml
	\
	rm	redhat-certification/sysdig.crd.yaml \
		redhat-certification/sysdig-operator.v${VERSION}.clusterserviceversion.yaml
	\
	git checkout redhat-certification
