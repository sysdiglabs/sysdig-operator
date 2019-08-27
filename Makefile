IMAGE = sysdiglabs/sysdig-operator
# Use same version than helm chart
PREVIOUS_VERSION = $(shell ls -d deploy/olm-catalog/sysdig-operator/*/ -t | head -n1 | cut -d"/" -f4)
VERSION = 1.4.13

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
	cat deploy/service_account.yaml >> bundle.yaml
	echo '---' >> bundle.yaml
	cat deploy/role_binding.yaml >> bundle.yaml
	echo '---' >> bundle.yaml
	cat deploy/operator.yaml >> bundle.yaml
	sed -i 's|REPLACE_IMAGE|docker.io/$(IMAGE):$(VERSION)|g' bundle.yaml

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

new-upstream: bundle.yaml build push operatorhub package-redhat
	sed -i "s/^VERSION = .*/VERSION = $(VERSION)/" Makefile
	git add bundle.yaml
	git add Makefile
	git commit -m "New Sysdig helm chart release $(VERSION)"
	git tag -f v$(VERSION)
	GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" git push origin HEAD:master
	GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" git push --tags -f

operatorhub:
	mkdir -p deploy/olm-catalog/sysdig-operator/$(VERSION)
	cp deploy/olm-catalog/sysdig-operator/sysdig-operator.template.clusterserviceversion.yaml deploy/olm-catalog/sysdig-operator/$(VERSION)/sysdig-operator.v$(VERSION).clusterserviceversion.yaml
	sed -i "s/PREVIOUS_VERSION/$(PREVIOUS_VERSION)/" deploy/olm-catalog/sysdig-operator/$(VERSION)/sysdig-operator.v$(VERSION).clusterserviceversion.yaml
	sed -i "s/VERSION/$(VERSION)/" deploy/olm-catalog/sysdig-operator/$(VERSION)/sysdig-operator.v$(VERSION).clusterserviceversion.yaml
	git add deploy/olm-catalog/sysdig-operator/$(VERSION)/sysdig-operator.v$(VERSION).clusterserviceversion.yaml
