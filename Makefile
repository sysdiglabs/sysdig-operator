IMAGE = sysdiglabs/sysdig-agent-operator
# Use same version than helm chart
VERSION = 1.4.0

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
