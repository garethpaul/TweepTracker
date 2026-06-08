.PHONY: lint test build verify

PYTHON ?= python3

lint:
	$(PYTHON) scripts/check_ios_project.py

test: lint
	@if command -v xcodebuild >/dev/null 2>&1; then \
		if find location_tracker.xcodeproj/xcshareddata/xcschemes -name '*.xcscheme' 2>/dev/null | grep -q .; then \
			xcodebuild -project location_tracker.xcodeproj -scheme location_tracker -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO test; \
		else \
			xcodebuild -project location_tracker.xcodeproj -target location_trackerTests -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build; \
		fi; \
	else \
		echo "iOS tests skipped: xcodebuild is not available on this host."; \
	fi

build:
	@if command -v xcodebuild >/dev/null 2>&1; then \
		xcodebuild -project location_tracker.xcodeproj -target location_tracker -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build; \
	else \
		echo "iOS build skipped: xcodebuild is not available on this host."; \
	fi

verify: lint test build
