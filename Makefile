#
# Copyright 2022 OpsMx, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License")
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

TARGETS=test local
PLATFORM=linux/amd64,linux/arm64
BUILDX=docker buildx build --pull --platform ${PLATFORM}
IMAGE_PREFIX=docker.flame.org/library/

IMAGE_TARGETS = otel-java

now := $(shell date -u +%Y%m%dT%H%M%S)

#
# Standard "whatever we are on now" image builds
#
.PHONY: images
images: $(addsuffix .ts, $(addprefix buildtime/,$(IMAGE_TARGETS)))

buildtime/%.ts:: buildtime ${all_deps} Dockerfile
	@$(eval GIT_BRANCH=$(shell git branch --show-current))
	@$(eval GIT_HASH=$(shell git rev-parse ${GIT_BRANCH}))
	docker build --pull \
		--tag ${IMAGE_PREFIX}$(patsubst %.ts,%,$(@F)):latest \
		--tag ${IMAGE_PREFIX}$(patsubst %.ts,%,$(@F)):v${now} \
		--build-arg GIT_HASH=${GIT_HASH} \
		--build-arg GIT_BRANCH=${GIT_BRANCH} \
		--target $(patsubst %.ts,%,$(@F))-image \
		.
	touch $@

#
# make a buildtime directory to hold the build timestamp files
buildtime:
	[ ! -d buildtime ] && mkdir buildtime

#
# Clean the world.
#

.PHONY: clean
clean:
	rm -f buildtime/*.ts
	rm -f bin/*

.PHONY: really-clean
really-clean: clean
