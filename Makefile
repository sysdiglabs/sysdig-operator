IMAGE = sysdiglabs/sysdig-operator
# Use same version than helm chart
VERSION = 1.4.0

.PHONY: build

build:
	helm fetch stable/sysdig --version $(VERSION) --untar --untardir helm-charts/
	operator-sdk build $(IMAGE):$(VERSION)
	rm -fr helm-charts/sysdig

push:
	docker push $(IMAGE):$(VERSION)

e2e:
	kubectl apply -f deploy/crds/sysdig_v1alpha1_sysdig_crd.yaml
	sed -i 's|REPLACE_IMAGE|docker.io/$(IMAGE):$(VERSION)|g' deploy/operator.yaml
	kubectl apply -f deploy/service_account.yaml
	kubectl apply -f deploy/role_binding.yaml
	kubectl apply -f deploy/operator.yaml
	sed -i 's|ACCESS_KEY|${SYSDIG_AGENT_ACCESS_KEY}|g' deploy/crds/sysdig_v1alpha1_sysdig_cr.yaml
	kubectl apply -f deploy/crds/sysdig_v1alpha1_sysdig_cr.yaml


e2e-clean:
	kubectl delete -f deploy/crds/sysdig_v1alpha1_sysdig_cr.yaml
	kubectl delete -f deploy/operator.yaml
	kubectl delete -f deploy/role_binding.yaml
	kubectl delete -f deploy/service_account.yaml
	kubectl delete -f deploy/crds/sysdig_v1alpha1_sysdig_crd.yaml
