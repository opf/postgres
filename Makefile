# Makefile for opf/postgres Docker image/container

SHELL := /bin/bash

# Configuration
IMAGE_NAME ?= openproject/postgres
PG_MAJOR ?= 19
DEBIAN_CODENAME ?= trixie
PLATFORMS ?= linux/amd64,linux/arm64

ifeq ($(filter $(PG_MAJOR),16 17 18 19),)
  $(error Unsupported PG_MAJOR '$(PG_MAJOR)'. Supported versions: 16, 17, 18, 19)
endif

.PHONY: help build build_multiarch push build-image

help: ## Show this help message
	@echo "Available targets:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'
	@echo ""

# Configure the shared build target for each output mode
build: BUILD_PLATFORM =
build: BUILD_OUTPUT = --load
build: build-image ## Build for local platform

build_multiarch: BUILD_PLATFORM = --platform $(PLATFORMS)
build_multiarch: BUILD_OUTPUT = --output type=oci,dest=postgres-test.tar
build_multiarch: build-image ## Build for all supported platforms

push: BUILD_PLATFORM = --platform $(PLATFORMS)
push: BUILD_OUTPUT = --push
push: build-image ## Build and push to Docker Hub

# Shared build implementation
build-image:
	@set -eu; \
	read -r PG_VERSION PG_MAJOR PGVECTOR_VERSION PGVECTOR_DEBIAN_VERSION <<< "$$(PG_MAJOR=$(PG_MAJOR) DEBIAN_CODENAME=$(DEBIAN_CODENAME) ./bin/get-versions.sh)"; \
	SHORT_TAG="$(IMAGE_NAME):$$PG_MAJOR"; \
	FULL_TAG="$(IMAGE_NAME):$$PG_VERSION-pgvector-$$PGVECTOR_VERSION"; \
	echo "Building $$SHORT_TAG and $$FULL_TAG"; \
	docker buildx build \
	  $(BUILD_PLATFORM) \
	  --build-arg PG_MAJOR=$$PG_MAJOR \
	  --build-arg DEBIAN_CODENAME=$(DEBIAN_CODENAME) \
	  --build-arg PGVECTOR_VERSION=$$PGVECTOR_DEBIAN_VERSION \
	  --tag "$$SHORT_TAG" \
	  --tag "$$FULL_TAG" \
	  $(BUILD_OUTPUT) \
	  .
