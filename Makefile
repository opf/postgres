# Makefile for opf/postgres Docker image/container
#
# Usage:
#   make build          - Build the Docker image

# Configuration
IMAGE_NAME ?= openproject/postgres
PG_MAJOR ?= 19
DEBIAN_CODENAME ?= trixie
PLATFORMS ?= linux/amd64,linux/arm64

ifeq ($(filter $(PG_MAJOR),16 17 18 19),)
  $(error Unsupported PG_MAJOR '$(PG_MAJOR)'. Supported versions: 16, 17, 18, 19)
endif


.PHONY: help build build_multiarch push

help: ## Show this help message
	@echo "Available targets:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'
	@echo ""

build: ## Build the Docker image
	@set -eu; \
	read -r PG_VERSION PG_MAJOR PGVECTOR_VERSION PGVECTOR_DEBIAN_VERSION <<< "$$(PG_MAJOR=$(PG_MAJOR) DEBIAN_CODENAME=$(DEBIAN_CODENAME) ./bin/get-versions.sh)"; \
	IMAGE_TAG="$(IMAGE_NAME):$$PG_VERSION-pgvector-$$PGVECTOR_VERSION"; \
	echo "Building $$IMAGE_TAG"; \
	docker buildx build \
	  --build-arg PG_MAJOR=$$PG_MAJOR \
	  --build-arg DEBIAN_CODENAME=$(DEBIAN_CODENAME) \
	  --build-arg PGVECTOR_VERSION=$$PGVECTOR_DEBIAN_VERSION \
	  --tag "$$IMAGE_TAG" \
	  --load \
	  .

build_multiarch: ## Build the Docker image for all platforms
	@set -eu; \
	read -r PG_VERSION PG_MAJOR PGVECTOR_VERSION PGVECTOR_DEBIAN_VERSION <<< "$$(PG_MAJOR=$(PG_MAJOR) DEBIAN_CODENAME=$(DEBIAN_CODENAME) ./bin/get-versions.sh)"; \
	IMAGE_TAG="$(IMAGE_NAME):$$PG_VERSION-pgvector-$$PGVECTOR_VERSION"; \
	docker buildx build \
	  --platform $(PLATFORMS) \
	  --build-arg PG_MAJOR=$$PG_MAJOR \
	  --build-arg DEBIAN_CODENAME=$(DEBIAN_CODENAME) \
	  --build-arg PGVECTOR_VERSION=$$PGVECTOR_DEBIAN_VERSION \
	  --tag "$$IMAGE_TAG" \
	  --output type=oci,dest=postgres-test.tar \
	  .

push: ## Build and push the Docker image
	@set -eu; \
	read -r PG_VERSION PG_MAJOR PGVECTOR_VERSION PGVECTOR_DEBIAN_VERSION <<< "$$(PG_MAJOR=$(PG_MAJOR) DEBIAN_CODENAME=$(DEBIAN_CODENAME) ./bin/get-versions.sh)"; \
	IMAGE_TAG="$(IMAGE_NAME):$$PG_VERSION-pgvector-$$PGVECTOR_VERSION"; \
	echo "Building $$IMAGE_TAG"; \
	docker buildx build \
	  --platform $(PLATFORMS) \
	  --build-arg PG_MAJOR=$$PG_MAJOR \
	  --build-arg DEBIAN_CODENAME=$(DEBIAN_CODENAME) \
	  --build-arg PGVECTOR_VERSION=$$PGVECTOR_DEBIAN_VERSION \
	  --tag "$$IMAGE_TAG" \
	  --push \
	  .
