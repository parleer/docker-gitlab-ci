SHELL := /bin/bash

-include make_env

export NS ?= flyinghippo
# export VERSION = $(shell grep ^DOCKER_IMAGE_VERSION= ../wpef | cut -d'=' -f2 | tr -d '"')

.PHONY: default
default: usage

.PHONY: usage
usage:
	@echo -e "Usage: make {target}\n" \
		"list:         list targets in this Makefile\n" \
		"vars:         dump some Makefile variables\n" \
		"build:        docker build\n" \
		"push:         docker push\n" \
		"release:      docker build and docker push\n"
# 	"clean:        clean dev files."

.PHONY: list
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'


.PHONY: guard-%
guard-%:
	@if [ "${${*}}" = "" ]; then \
	    echo "Environment variable $* not set"; \
	    exit 1; \
	fi

.PHONY: vars
vars: # guard-VERSION
	@echo MAKEFILE_LIST=$(lastword $(MAKEFILE_LIST))
	@echo NS=$(NS)
#	@echo VERSION=$(VERSION)
	@echo SUBMAKEFILES=$(SUBMAKEFILES)
	@echo SUBDIRS=$(SUBDIRS)
	@echo TARGETS=$(TARGETS)
	@echo SUBDIRS_TARGETS=$(SUBDIRS_TARGETS)

################################################################################
# Simple recursive example
# all:
# 	@for a in $$(ls); do \
# 		if [ -d $$a ]; then \
# 			echo "processing folder $$a"; \
# 			$(MAKE) -C $$a; \
# 		fi; \
# 	done;
# 	@echo "Done!"

################################################################################
# Better recursive make, allowing target to be passed to all-%
# SUBMAKEFILES = $(shell find . -mindepth 2 -maxdepth 3 -type f -name Makefile)
# SUBDIRS = $(filter-out ./,$(dir $(SUBMAKEFILES)))
# .PHONY: all-% build push release
# all-%:
# 	for dir in $(SUBDIRS); do \
# 		echo $(MAKE) -C $$dir -e NS=$(NS) -e VERSION=$(VERSION) ${*}; \
# 	done
# build-all: all-build
# push-all: all-push
# release-all: all-release


################################################################################
# Makefile-ish recursive make
# https://stackoverflow.com/questions/11206500/compile-several-projects-with-makefile-but-stop-on-first-broken-build/11206700#11206700
# 
# NOTE: 
#   If we wanted to allow /php/Makefile to exist *while simultaneously* allowing
#   our root Makefile to build /php/7_3/Makefile, we'd a way to exclude the duplciate
#   php/Makefile targers from the global build target.
# 
#   Otherwise, 'make build' will build php/build, which will recurse into 
#   php/7_3/build and php/7_4/build, and then php/7_3/build and php/7_4/build
#   will get built again by the root recurse.
#  

SUBMAKEFILES = $(shell find . -mindepth 2 -maxdepth 4 -type f -name Makefile)
SUBDIRS = $(filter-out ./,$(dir $(SUBMAKEFILES)))
TARGETS := info build tag tag-latest push release # whatever else, but must not contain '/'
SUBDIRS_TARGETS := $(foreach t,$(TARGETS),$(addsuffix $t,$(SUBDIRS)))
.PHONY: $(TARGETS) $(SUBDIRS_TARGETS)

# static pattern rule, expands into:
# all clean : % : foo/.% bar/.%
$(TARGETS) : % : $(addsuffix %,$(SUBDIRS))
	@echo 'Done "$*" target'

# here, for foo/.all:
#   $(@D) is foo
#   $(@F) is .all, with leading period
#   $(@F:.%=%) is just all
$(SUBDIRS_TARGETS) :
	@$(MAKE) -C $(@D) $(@F:.%=%)

# clean:
# 	rm -f *.tgz
# 	rm -f *.zip
# 	rm -fR package/
# 	npm prune --production

