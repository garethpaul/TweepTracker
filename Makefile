.DEFAULT_GOAL := check
.PHONY: __repository-make-authority build check lint root-test test verify

PUBLIC_TARGETS := build check lint root-test test verify

PYTHON ?= python3
override PYTHON := $(value PYTHON)
export PYTHON
override REPOSITORY_MAKE_DOLLAR := $$
override REPOSITORY_MAKE_OPEN := (
ifneq ($(findstring $(REPOSITORY_MAKE_DOLLAR)$(REPOSITORY_MAKE_OPEN),$(value PYTHON)),)
$(error PYTHON must be a literal executable path, not Make syntax)
endif
RUN_LEGACY_XCODE ?= 0
override RUN_LEGACY_XCODE := $(value RUN_LEGACY_XCODE)
ifneq ($(filter-out 0 1,$(value RUN_LEGACY_XCODE)),)
$(error RUN_LEGACY_XCODE must be the literal value 0 or 1)
endif
override SHELL := /bin/sh
override .SHELLFLAGS := -c

ifneq ($(filter command line,$(origin MAKEFLAGS)),)
$(error MAKEFLAGS must not be overridden for repository verification)
endif
override REPOSITORY_MAKE_FIRST_FLAGS := $(firstword $(MAKEFLAGS))
ifneq ($(filter -%,$(REPOSITORY_MAKE_FIRST_FLAGS)),)
override REPOSITORY_MAKE_FIRST_FLAGS :=
endif
override REPOSITORY_MAKE_SHORT_FLAGS := $(REPOSITORY_MAKE_FIRST_FLAGS) $(filter-out --%,$(filter -%,$(MAKEFLAGS)))
ifneq ($(findstring n,$(REPOSITORY_MAKE_SHORT_FLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(findstring t,$(REPOSITORY_MAKE_SHORT_FLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(findstring q,$(REPOSITORY_MAKE_SHORT_FLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(findstring i,$(REPOSITORY_MAKE_SHORT_FLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(filter --just-print --dry-run --recon --touch --question --ignore-errors,$(MAKEFLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(strip $(MAKEFILES)),)
$(error MAKEFILES must be empty; repository verification requires this Makefile to be loaded alone)
endif
override MAKEFILES :=
ifneq ($(origin MAKEFILE_LIST),file)
$(error MAKEFILE_LIST must not be overridden)
endif
override REPOSITORY_MAKEFILE := $(lastword $(MAKEFILE_LIST))
override REPOSITORY_ROOT := $(abspath $(dir $(REPOSITORY_MAKEFILE)))
override ROOT := $(REPOSITORY_ROOT)
export ROOT

$(PUBLIC_TARGETS): override SHELL := /bin/sh
$(PUBLIC_TARGETS): override .SHELLFLAGS := -c
$(PUBLIC_TARGETS): override ROOT := $(REPOSITORY_ROOT)
$(PUBLIC_TARGETS): __repository-make-authority

__repository-make-authority:
	@:

lint:
	"$$PYTHON" "$$ROOT/scripts/check_ios_project.py"

test: lint
	"$$PYTHON" "$$ROOT/scripts/test_review_contracts.py"
	@if [ "$(RUN_LEGACY_XCODE)" = "1" ] && command -v xcodebuild >/dev/null 2>&1; then \
		if find "$$ROOT/location_tracker.xcodeproj/xcshareddata/xcschemes" -name '*.xcscheme' 2>/dev/null | grep -q .; then \
			cd "$$ROOT" && xcodebuild -project location_tracker.xcodeproj -scheme location_tracker -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO test; \
		else \
			cd "$$ROOT" && xcodebuild -project location_tracker.xcodeproj -target location_trackerTests -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build; \
		fi; \
	elif [ "$(RUN_LEGACY_XCODE)" = "1" ]; then \
		echo "iOS tests skipped: xcodebuild is not available on this host."; \
	else \
		echo "iOS tests skipped: set RUN_LEGACY_XCODE=1 only with a compatible historical toolchain."; \
	fi

build:
	@if [ "$(RUN_LEGACY_XCODE)" = "1" ] && command -v xcodebuild >/dev/null 2>&1; then \
		cd "$$ROOT" && xcodebuild -project location_tracker.xcodeproj -target location_tracker -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build; \
	elif [ "$(RUN_LEGACY_XCODE)" = "1" ]; then \
		echo "iOS build skipped: xcodebuild is not available on this host."; \
	else \
		echo "iOS build skipped: set RUN_LEGACY_XCODE=1 only with a compatible historical toolchain."; \
	fi

root-test:
	/bin/sh "$$ROOT/scripts/test-makefile-authority.sh"
	/bin/sh "$$ROOT/scripts/test-make-wrapper.sh"

verify: root-test lint test build

check: verify
