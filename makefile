DOCKER_REGISTRY := mathematiguy
WORKSPACE ?= /home/$(USER)
UID ?= 1000
GID ?= 1000
UNAME ?= spacemacser
TIME_ZONE ?= $(shell date +"%Z")
DOCKER_ARGS ?= 
GIT_TAG ?= $(shell git log --oneline | head -n1 | awk '{print $$1}')
VERSION ?= emacs25
IMAGE_NAME := spacemacs-$(VERSION)
IMAGE := $(DOCKER_REGISTRY)/$(IMAGE_NAME)
RUN ?= docker run $(DOCKER_ARGS) --rm -v $$(pwd):/work -w /work -u $(UID):$(GID) $(IMAGE)

spacemacs: docker
	docker run -it \
	 -e DISPLAY="unix$$DISPLAY" \
	 -e UNAME=$(UNAME)\
	 -e UID=$(UID) \
	 -e TZ=$(TIME_ZONE) \
	 -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
	 -v /etc/localtime:/etc/localtime:ro \
	 -v /etc/machine-id:/etc/machine-id:ro \
	 -v /var/run/dbus:/var/run/dbus \
	 -v $(WORKSPACE):/mnt/workspace \
	 -v /var/run/docker.sock:/var/run/docker.sock \
	 $(IMAGE)

.PHONY: docker
docker:
	docker build --tag $(IMAGE):$(GIT_TAG) -f Dockerfile.$(VERSION) .
	docker tag $(IMAGE):$(GIT_TAG) $(IMAGE):latest

.PHONY: docker-push
docker-push:
	docker push $(IMAGE):$(GIT_TAG)
	docker push $(IMAGE):latest

.PHONY: docker-pull
docker-pull:
	docker pull $(IMAGE):$(GIT_TAG)
	docker tag $(IMAGE):$(GIT_TAG) $(IMAGE):latest

.PHONY: enter
enter: DOCKER_ARGS=-it
enter:
	$(RUN) bash

.PHONY: enter-root
enter-root: DOCKER_ARGS=-it
enter-root: UID=root
enter-root: GID=root
enter-root:
	$(RUN) bash

