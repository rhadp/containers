# RHAS Container Images Makefile
# Build container images locally using Podman

# Default registry and namespace
REGISTRY ?= ghcr.io
NAMESPACE ?= rhadp

# Image names and tags
RUNTIME_IMAGE = $(REGISTRY)/$(NAMESPACE)/runtime
PIPELINE_IMAGE = $(REGISTRY)/$(NAMESPACE)/pipeline
CODESPACES_IMAGE = $(REGISTRY)/$(NAMESPACE)/codespaces
BUILDER_IMAGE = $(REGISTRY)/$(NAMESPACE)/builder
TOOLS_IMAGE = $(REGISTRY)/$(NAMESPACE)/tools

TAG ?= latest

# Build tool
CONTAINER_TOOL ?= podman

# Runtime container name (override with `make run CONTAINER_NAME=my-container`)
CONTAINER_NAME ?= rhas-runtime

# Build arguments
BUILD_ARGS ?= --build-arg TARGETARCH=$(shell uname -m | sed 's/x86_64/amd64/')

.PHONY: help all build-all base builder runtime pipeline codespaces clean clean-all push-all

# Build all images
build-all: update tools runtime builder pipeline codespaces
	@echo "✅ All images built successfully!"

update:
	@echo "🔨 Updating base images..."
	$(CONTAINER_TOOL) pull registry.redhat.io/ubi10:10.2
	$(CONTAINER_TOOL) pull registry.redhat.io/ubi10/go-toolset:latest
	$(CONTAINER_TOOL) pull registry.redhat.io/devspaces/udi-base-rhel10:3.29
	$(CONTAINER_TOOL) pull registry.redhat.io/rhel10/s2i-core:10.2
	$(CONTAINER_TOOL) pull ghcr.io/astral-sh/uv
	@echo "✅ Base images updated"

# Build the runtime image
runtime:
	@echo "🔨 Building runtime image..."
	$(CONTAINER_TOOL) build $(BUILD_ARGS) \
		-f containers/runtime/Containerfile \
		-t $(RUNTIME_IMAGE):$(TAG) \
		containers/runtime/
	@echo "✅ Runtime image built: $(RUNTIME_IMAGE):$(TAG)"

# Build the tools image
tools:
	@echo "🔨 Building tools image..."
	$(CONTAINER_TOOL) build $(BUILD_ARGS) \
		-f containers/tools/Containerfile \
		-t $(TOOLS_IMAGE):$(TAG) \
		containers/tools/
	@echo "✅ Tools image built: $(TOOLS_IMAGE):$(TAG)"

# Build the pipeline image
pipeline: runtime
	@echo "🔨 Building pipeline image..."
	$(CONTAINER_TOOL) build $(BUILD_ARGS) \
		-f containers/pipeline/Containerfile \
		-t $(PIPELINE_IMAGE):$(TAG) \
		containers/pipeline/
	@echo "✅ Pipeline image built: $(PIPELINE_IMAGE):$(TAG)"

# Build the builder image
builder:
	@echo "🔨 Building builder image..."
	$(CONTAINER_TOOL) build $(BUILD_ARGS) \
		-f containers/builder/Containerfile \
		-t $(BUILDER_IMAGE):$(TAG) \
		containers/builder/
	@echo "✅ Builder image built: $(BUILDER_IMAGE):$(TAG)"

# Build the codespaces image (depends on builder)
codespaces: 
	@echo "🔨 Building codespaces image..."
	$(CONTAINER_TOOL) build $(BUILD_ARGS) \
		-f containers/codespaces/Containerfile \
		-t $(CODESPACES_IMAGE):$(TAG) \
		containers/codespaces/
	@echo "✅ Codespaces image built: $(CODESPACES_IMAGE):$(TAG)"

# Clean up locally built images
clean:
	@echo "🧹 Cleaning up locally built images..."
	-$(CONTAINER_TOOL) rmi $(CODESPACES_IMAGE):$(TAG) 2>/dev/null || true
	-$(CONTAINER_TOOL) rmi $(PIPELINE_IMAGE):$(TAG) 2>/dev/null || true
	-$(CONTAINER_TOOL) rmi $(BUILDER_IMAGE):$(TAG) 2>/dev/null || true
	-$(CONTAINER_TOOL) rmi $(RUNTIME_IMAGE):$(TAG) 2>/dev/null || true
	-$(CONTAINER_TOOL) rmi $(TOOLS_IMAGE):$(TAG) 2>/dev/null || true
	@echo "✅ Local images cleaned"

# Clean up all related images including base images
clean-all: clean
	@echo "🧹 Cleaning up all related images..."
	-$(CONTAINER_TOOL) rmi registry.redhat.io/ubi10:10.2  2>/dev/null || true
	-$(CONTAINER_TOOL) rmi registry.redhat.io/ubi10/go-toolset:latest 2>/dev/null || true
	-$(CONTAINER_TOOL) rmi registry.redhat.io/devspaces/udi-base-rhel10:3.29 2>/dev/null || true
	-$(CONTAINER_TOOL) rmi registry.redhat.io/rhel10/s2i-core:10.2 2>/dev/null || true
	-$(CONTAINER_TOOL) rmi ghcr.io/astral-sh/uv 2>/dev/null || true
	-$(CONTAINER_TOOL) system prune -f 2>/dev/null || true
	@echo "✅ All images cleaned"

