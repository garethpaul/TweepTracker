.PHONY: build check lint test verify

override ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PYTHON ?= python3
RUN_LEGACY_XCODE ?= 0

lint:
	$(PYTHON) "$(ROOT)/scripts/check_ios_project.py"

test: lint
	$(PYTHON) "$(ROOT)/scripts/test_review_contracts.py"
	@if [ "$(RUN_LEGACY_XCODE)" = "1" ] && command -v xcodebuild >/dev/null 2>&1; then \
		if find "$(ROOT)/location_tracker.xcodeproj/xcshareddata/xcschemes" -name '*.xcscheme' 2>/dev/null | grep -q .; then \
			cd "$(ROOT)" && xcodebuild -project location_tracker.xcodeproj -scheme location_tracker -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO test; \
		else \
			cd "$(ROOT)" && xcodebuild -project location_tracker.xcodeproj -target location_trackerTests -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build; \
		fi; \
	elif [ "$(RUN_LEGACY_XCODE)" = "1" ]; then \
		echo "iOS tests skipped: xcodebuild is not available on this host."; \
	else \
		echo "iOS tests skipped: set RUN_LEGACY_XCODE=1 only with a compatible historical toolchain."; \
	fi

build:
	@if [ "$(RUN_LEGACY_XCODE)" = "1" ] && command -v xcodebuild >/dev/null 2>&1; then \
		cd "$(ROOT)" && xcodebuild -project location_tracker.xcodeproj -target location_tracker -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build; \
	elif [ "$(RUN_LEGACY_XCODE)" = "1" ]; then \
		echo "iOS build skipped: xcodebuild is not available on this host."; \
	else \
		echo "iOS build skipped: set RUN_LEGACY_XCODE=1 only with a compatible historical toolchain."; \
	fi

verify: lint test build

check: verify
