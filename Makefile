REGISTRY = hub.mtzanidakis.com
IMAGE = wordpress
VERSION = 6.2.2
CHECKSUM = a355d1b975405a391c4a78f988d656b375683fb2

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
