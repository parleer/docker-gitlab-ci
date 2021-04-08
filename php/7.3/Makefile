SHELL := /bin/bash

-include make_env

NS ?= flyinghippo
VERSION ?= php7.3
IMAGE_NAME ?= gitlab-ci
CONTAINER_NAME ?= $(IMAGE_NAME)
CONTAINER_INSTANCE ?= default

default: usage

usage:
	@echo -e "Usage: make {target}\n" \
		"list:         list targets in this Makefile\n" \
		"vars:         dump some Makefile variables\n" \
		"build:        docker build\n" \
		"push:         docker push\n" \
		"shell:        docker run /bin/bash\n" \
		"tag:          docker tag VERSION NEW_VERSION\n" \
		"tag-latest:   docker tag VERSION latest\n" \
		"rm:           docker rm\n" \
		"release:      docker build && docker push\n" \
		"clean:        clean dev files."

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

.PHONY: guard-%
guard-%:
	@if [ "${${*}}" = "" ]; then \
	    echo "Environment variable $* not set"; \
	    exit 1; \
	fi

vars info:
	@echo NS=$(NS) IMAGE_NAME=$(IMAGE_NAME) VERSION=$(VERSION)

build: Dockerfile
	docker build -t $(NS)/$(IMAGE_NAME):$(VERSION) -f Dockerfile .

push:
	docker push $(NS)/$(IMAGE_NAME):$(VERSION)

shell:
	 docker run --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) -i -t $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION) /bin/bash

tag: guard-NEW_VERSION
	docker tag $(NS)/$(IMAGE_NAME):$(VERSION) $(NS)/$(IMAGE_NAME):$(NEW_VERSION)

tag-latest: NEW_VERSION = latest
tag-latest: tag

# run:
# 	@echo run

# start:
# 	@echo start

# stop:
# 	@echo stop

rm:
	docker rm $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

release: build
  make push -e VERSION=$(VERSION)


.PHONY: default usage vars info list build push shell tag rm release
