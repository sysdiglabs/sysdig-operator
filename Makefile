IMAGE = sysdiglabs/sysdig-operator
# Use same version than helm chart
VERSION = v1.3.2

.PHONY: build

build:
	operator-sdk build $(IMAGE):$(VERSION)

push:
	docker push $(IMAGE):$(VERSION)
