SHELL := /bin/bash
OS := $(shell uname | tr '[:upper:]' '[:lower:]')

GO_VARS := GO111MODULE=on GO15VENDOREXPERIMENT=1 CGO_ENABLED=0
BUILDFLAGS := ''

APP_NAME := jx-app-test-lifecycle
MAIN := cmd/main.go

BUILD_DIR=build
PACKAGE_DIRS := $(shell go list ./...)
PKGS := $(subst  :,_,$(PACKAGE_DIRS))
PLATFORMS := windows linux darwin
os = $(word 1, $@)

VERSION ?= $(shell cat VERSION)

# setting some defaults for skaffold
DOCKER_REGISTRY ?= docker.io

FGT := $(GOPATH)/bin/fgt
GOLINT := $(GOPATH)/bin/golint

.PHONY : build
build: linux test  ## Compiles and tests

.PHONY : all
all: linux test check ## Compiles, tests and checks sources

.PHONY: $(PLATFORMS)
$(PLATFORMS):	
	$(GO_VARS) GOOS=$(os) GOARCH=amd64 go build -ldflags $(BUILDFLAGS) -o $(BUILD_DIR)/$(APP_NAME) $(MAIN)

.PHONY : test
test: ## Runs unit tests
	$(GO_VARS) go test -v $(PACKAGE_DIRS) 

.PHONY : fmt
fmt: ## Re-formates Go source files according to standard
	@$(GO_VARS) go fmt $(PACKAGE_DIRS)

.PHONY : clean
clean: ## Deletes the build directory with all generated artefacts
	rm -rf $(BUILD_DIR)

check: $(GOLINT) $(FGT)
	@echo "LINTING"
	@$(FGT) $(GOLINT) $(PACKAGE_DIRS)
	@echo "VETTING"
	@$(GO_VARS) $(FGT) go vet $(PACKAGE_DIRS)

.PHONY : run
run: $(OS) ## Runs the app locally
	$(BUILD_DIR)/$(APP_NAME)

.PHONY: watch
watch: ## Watches for file changes in Go source files and re-runs 'skaffold build' (Requires entr)
	find . -name "*.go" | entr -s 'make skaffold-build' 

.PHONY: skaffold-build
skaffold-build: linux ## Runs 'skaffold build'
	DOCKER_REGISTRY=$(DOCKER_REGISTRY) VERSION=$(VERSION) skaffold build -f skaffold.yaml

.PHONY: skaffold-run
skaffold-run: linux ## Runs 'skaffold run'
	DOCKER_REGISTRY=$(DOCKER_REGISTRY) VERSION=$(VERSION) skaffold run -f skaffold.yaml -p dev

.PHONY: help
help: ## Prints this help
	@grep -E '^[^.]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-40s\033[0m %s\n", $$1, $$2}' | sort

.PHONY: release
release: linux test check skaffold-build ## Creates a release
	cd charts/$(APP_NAME) && jx step helm release
	jx step changelog --version v$(VERSION) -p $$(git merge-base $$(git for-each-ref --sort=-creatordate --format='%(objectname)' refs/tags | sed -n 2p) master) -r $$(git merge-base $$(git for-each-ref --sort=-creatordate --format='%(objectname)' refs/tags | sed -n 1p) master)

.PHONY: release-branch
release-branch:  ## Creates release branch and pushes release
	git checkout -b release-v$(VERSION)
	git add --all
	git commit -m "release $(VERSION)" --allow-empty # if first release then no version update is performed
	git tag -fa v$(VERSION) -m "Release version $(VERSION)"

# Targets to get some Go tools
$(FGT):
	GO111MODULE=off go get github.com/GeertJohan/fgt

$(GOLINT):
	GO111MODULE=off go get github.com/golang/lint/golint
