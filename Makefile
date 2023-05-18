REGISTRY = hub.mtzanidakis.com
IMAGE = wordpress
VERSION = 6.2.1
CHECKSUM = 802914e642da79b1910bdffaee16665a499bc867

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
