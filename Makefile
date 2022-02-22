REGISTRY = hub.mtzanidakis.com
IMAGE = wordpress
VERSION = 5.9.1

.PHONY: all
all: container-push

.PHONY: container
container:
	docker build \
		--build-arg VERSION=$(VERSION) \
		--tag $(REGISTRY)/$(IMAGE):$(VERSION) .
	docker tag $(REGISTRY)/$(IMAGE):$(VERSION) $(REGISTRY)/$(IMAGE):latest


.PHONY: container-push
container-push: container
	docker push $(REGISTRY)/$(IMAGE):$(VERSION)
	docker push $(REGISTRY)/$(IMAGE):latest
