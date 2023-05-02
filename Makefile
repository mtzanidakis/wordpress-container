REGISTRY = hub.mtzanidakis.com
IMAGE = wordpress
VERSION = 6.2
CHECKSUM = 6fcc4c21b107a355e3df0798851d41e0d85f0e6d

.PHONY: all
all: container-push

.PHONY: container
container:
	docker build \
		--build-arg VERSION=$(VERSION) \
		--build-arg CHECKSUM=$(CHECKSUM) \
		--tag $(REGISTRY)/$(IMAGE):$(VERSION) .
	docker tag $(REGISTRY)/$(IMAGE):$(VERSION) $(REGISTRY)/$(IMAGE):latest


.PHONY: container-push
container-push: container
	docker push $(REGISTRY)/$(IMAGE):$(VERSION)
	docker push $(REGISTRY)/$(IMAGE):latest
