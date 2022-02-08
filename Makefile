REGISTRY = hub.mtzanidakis.com
IMAGE = wordpress
VERSION = 5.9

.PHONY: container
container:
	docker build \
		--build-arg VERSION=$(VERSION) \
		--tag $(REGISTRY)/$(IMAGE):$(VERSION) .


.PHONY: container-push
container-push: container
	docker push $(REGISTRY)/$(IMAGE):$(VERSION)
