REGISTRY = hub.mtzanidakis.com
IMAGE = wordpress
VERSION = 6.1.1
CHECKSUM = 80f0f829645dec07c68bcfe0a0a1e1d563992fcb

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
