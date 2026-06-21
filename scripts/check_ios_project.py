#!/usr/bin/env python3
"""Static verification for the legacy TweepTracker Xcode project."""

from pathlib import Path
import json
import plistlib
import re
import sys
import xml.etree.ElementTree as ET


ROOT = Path(__file__).resolve().parents[1]
PROJECT_FILE = ROOT / "location_tracker.xcodeproj/project.pbxproj"
CI_WORKFLOW = ROOT / ".github/workflows/check.yml"
IMAGE_TRANSPORT_PLAN = ROOT / "docs/plans/2026-06-10-profile-image-transport.md"
ANNOTATION_REUSE_PLAN = ROOT / "docs/plans/2026-06-10-annotation-image-reuse.md"
LOCATION_LOG_PRIVACY_PLAN = ROOT / "docs/plans/2026-06-12-location-log-privacy.md"
URLSESSION_PLAN = ROOT / "docs/plans/2026-06-13-profile-image-urlsession.md"
IMAGE_TASK_CANCELLATION_PLAN = ROOT / "docs/plans/2026-06-13-profile-image-task-cancellation.md"
IMAGE_REQUEST_GENERATION_PLAN = ROOT / "docs/plans/2026-06-13-profile-image-request-generation.md"
ROOT_OVERRIDE_PLAN = ROOT / "docs/plans/2026-06-14-make-root-override-protection.md"
LEGACY_SDK_PLAN = ROOT / "docs/plans/2026-06-14-legacy-sdk-compatibility.md"
FABRIC_CREDENTIAL_PLAN = ROOT / "docs/plans/2026-06-14-fabric-build-credential-removal.md"
RUNTIME_ERROR_LOG_PRIVACY_PLAN = ROOT / "docs/plans/2026-06-16-runtime-error-log-privacy.md"
MAP_REFRESH_GENERATION_PLAN = ROOT / "docs/plans/2026-06-17-map-refresh-request-generation.md"
CHECKOUT_ACTION = "actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10"
SETUP_PYTHON_ACTION = "actions/setup-python@a309ff8b426b58ec0e2a45f0f869d46889d02405"
ALLOWED_ACTIONS = {"actions/checkout", "actions/setup-python"}


def fail(message):
    print(f"check_ios_project.py: {message}", file=sys.stderr)
    return 1


def read_text(relative_path):
    return (ROOT / relative_path).read_text(encoding="utf-8")


def require(condition, message):
    if not condition:
        raise AssertionError(message)


def load_plist(relative_path):
    with (ROOT / relative_path).open("rb") as plist_file:
        return plistlib.load(plist_file)


def check_project_manifest_references():
    project = PROJECT_FILE.read_text(encoding="utf-8")
    plist_paths = sorted(set(re.findall(r"INFOPLIST_FILE = ([^;]+);", project)))
    require(plist_paths, "project must reference Info.plist files")

    for plist_path in plist_paths:
        path = ROOT / plist_path.strip('"')
        require(path.exists(), f"{plist_path} is referenced by Xcode but not checked in")
        load_plist(plist_path.strip('"'))

    require("Storyboard.storyboard in Resources" in project, "main storyboard must remain bundled")
    require("location_trackerTests.swift in Sources" in project, "unit test source must remain compiled")
    require("TwitterResponse.swift in Sources" in project, "Twitter response validator must be compiled")
    require("Fabric.framework/run" not in project, "project must not run Fabric with tracked credentials")
    require("PBXShellScriptBuildPhase" not in project, "project must not contain shell-script build phases")


def check_app_plist_contract():
    info = load_plist("location_tracker/Info.plist")
    require(info["CFBundlePackageType"] == "APPL", "app bundle package type must be APPL")
    require(info["CFBundleExecutable"] == "$(EXECUTABLE_NAME)", "app executable must use Xcode substitution")
    require(info["UIMainStoryboardFile"] == "Storyboard", "app must launch the bundled Storyboard.storyboard")
    require(info["UILaunchStoryboardName"] == "LaunchScreen", "app must keep the launch screen reference")
    require("_" not in info["CFBundleIdentifier"], "bundle identifier must not contain underscores")
    require("NSAppTransportSecurity" not in info, "app must not weaken App Transport Security")
    for credential_key in (
        "FabricAPIKey",
        "TwitterKitConsumerKey",
        "TwitterKitConsumerSecret",
        "TwitterConsumerKey",
        "TwitterConsumerSecret",
    ):
        require(credential_key not in info, f"app plist must not contain {credential_key}")


def check_test_plist_contract():
    info = load_plist("location_trackerTests/Info.plist")
    require(info["CFBundlePackageType"] == "BNDL", "test bundle package type must be BNDL")
    require(info["CFBundleExecutable"] == "$(EXECUTABLE_NAME)", "test executable must use Xcode substitution")
    require(info["CFBundleIdentifier"].endswith(".tests"), "test bundle identifier must be test-specific")


def check_resources_parse():
    for relative_path in [
        "location_tracker/Storyboard.storyboard",
        "location_tracker/Base.lproj/LaunchScreen.xib",
    ]:
        ET.parse(ROOT / relative_path)

    for path in (ROOT / "location_tracker/Images.xcassets").rglob("Contents.json"):
        json.loads(path.read_text(encoding="utf-8"))


def check_docs_plans():
    plan_dir = ROOT / "docs" / "plans"
    require(plan_dir.is_dir(), "docs/plans must exist")
    require(
        (plan_dir / "2026-06-09-timeline-location-completion.md").exists(),
        "docs/plans/2026-06-09-timeline-location-completion.md is missing",
    )
    require(
        (plan_dir / "2026-06-09-profile-image-completion.md").exists(),
        "docs/plans/2026-06-09-profile-image-completion.md is missing",
    )
    require(
        (plan_dir / "2026-06-09-coordinate-number-validation.md").exists(),
        "docs/plans/2026-06-09-coordinate-number-validation.md is missing",
    )
    require(
        (plan_dir / "2026-06-10-ci-baseline.md").exists(),
        "docs/plans/2026-06-10-ci-baseline.md is missing",
    )
    require(IMAGE_TRANSPORT_PLAN.exists(), "docs/plans/2026-06-10-profile-image-transport.md is missing")
    require(ANNOTATION_REUSE_PLAN.exists(), "docs/plans/2026-06-10-annotation-image-reuse.md is missing")
    require(
        LOCATION_LOG_PRIVACY_PLAN.exists(),
        "docs/plans/2026-06-12-location-log-privacy.md is missing",
    )
    require(
        URLSESSION_PLAN.exists(),
        "docs/plans/2026-06-13-profile-image-urlsession.md is missing",
    )
    require(
        IMAGE_TASK_CANCELLATION_PLAN.exists(),
        "docs/plans/2026-06-13-profile-image-task-cancellation.md is missing",
    )
    require(
        IMAGE_REQUEST_GENERATION_PLAN.exists(),
        "docs/plans/2026-06-13-profile-image-request-generation.md is missing",
    )
    require(
        ROOT_OVERRIDE_PLAN.exists(),
        "docs/plans/2026-06-14-make-root-override-protection.md is missing",
    )
    require(
        LEGACY_SDK_PLAN.exists(),
        "docs/plans/2026-06-14-legacy-sdk-compatibility.md is missing",
    )
    require(
        FABRIC_CREDENTIAL_PLAN.exists(),
        "docs/plans/2026-06-14-fabric-build-credential-removal.md is missing",
    )
    require(
        RUNTIME_ERROR_LOG_PRIVACY_PLAN.exists(),
        "docs/plans/2026-06-16-runtime-error-log-privacy.md is missing",
    )
    require(
        MAP_REFRESH_GENERATION_PLAN.exists(),
        "docs/plans/2026-06-17-map-refresh-request-generation.md is missing",
    )

    plans = sorted(plan_dir.glob("*.md"))
    require(plans, "docs/plans must contain completed maintenance plans")

    for plan in plans:
        text = plan.read_text(encoding="utf-8")
        require("status: completed" in text.lower(), f"{plan.name} must be completed")
        require("make check" in text, f"{plan.name} must document make check verification")

    legacy_plan = LEGACY_SDK_PLAN.read_text(encoding="utf-8")
    for evidence in (
        "repository and external-directory `make check` passed",
        "hostile legacy SDK documentation mutations were rejected",
    ):
        require(evidence in legacy_plan, f"legacy SDK plan must record verification evidence: {evidence}")

    runtime_error_plan = RUNTIME_ERROR_LOG_PRIVACY_PLAN.read_text(encoding="utf-8").lower()
    for evidence in (
        "repository and external-directory `make check` passed",
        "seven isolated raw-error-log mutations were rejected",
    ):
        require(
            evidence in runtime_error_plan,
            f"runtime error log privacy plan must record verification evidence: {evidence}",
        )

    map_refresh_plan = MAP_REFRESH_GENERATION_PLAN.read_text(encoding="utf-8").lower()
    for evidence in (
        "repository and external-directory `make check` passed",
        "ten isolated map-refresh-generation mutations were rejected",
    ):
        require(
            evidence in map_refresh_plan,
            f"map refresh generation plan must record verification evidence: {evidence}",
        )

    for relative_path in ("README.md", "SECURITY.md", "VISION.md", "CHANGES.md"):
        require(
            "legacy sdk compatibility boundary" in read_text(relative_path).lower(),
            f"{relative_path} must document the legacy SDK compatibility boundary",
        )
        require(
            "runtime error log privacy" in read_text(relative_path).lower(),
            f"{relative_path} must document runtime error log privacy",
        )
        require(
            "map refresh generation" in read_text(relative_path).lower(),
            f"{relative_path} must document map refresh generation ownership",
        )

    project = PROJECT_FILE.read_text(encoding="utf-8")
    app_delegate = read_text("location_tracker/AppDelegate.swift")
    require(
        project.count("IPHONEOS_DEPLOYMENT_TARGET = 8.0;") == 2,
        "project must retain both iOS 8.0 deployment settings",
    )
    require(
        project.count("IPHONEOS_DEPLOYMENT_TARGET = 8.1;") == 2,
        "project must retain both iOS 8.1 deployment settings",
    )
    require("@UIApplicationMain" in app_delegate, "Swift 2-era app entry point must remain explicit")
    require(
        "UIApplication.sharedApplication()" in app_delegate,
        "Swift 2-era UIKit syntax must remain explicit",
    )

    readme = read_text("README.md")
    for contract in (
        "### Legacy SDK Compatibility Boundary",
        "iOS 8.0 and 8.1 deployment settings",
        "Swift 2-era UIKit and app-delegate syntax",
        "TwitterKit, Fabric, and Crashlytics are vendored historical binaries",
        "Live Twitter login, Twitter API, map, and crash-reporting compatibility are",
        "local untracked credentials",
        "portable `make check` gate",
        "current Xcode or current Swift is not claimed",
    ):
        require(contract in readme, f"README legacy SDK boundary is missing: {contract}")


def check_ci_baseline_docs():
    require(CI_WORKFLOW.exists(), ".github/workflows/check.yml is missing")
    workflow = CI_WORKFLOW.read_text(encoding="utf-8")
    for contract in (
        "  push:\n",
        "pull_request:",
        "workflow_dispatch:",
        "permissions:\n  contents: read\n\nconcurrency:",
        "group: check-${{ github.workflow }}-${{ github.ref }}",
        "cancel-in-progress: true",
        "runs-on: ubuntu-24.04",
        "timeout-minutes: 5",
        f"{CHECKOUT_ACTION} # v6.0.3",
        f"{SETUP_PYTHON_ACTION} # v6.2.0",
        "persist-credentials: false",
        'python-version: "3.12"',
        "run: make check",
    ):
        require(contract in workflow, f"CI workflow must include {contract!r}")
    require("ubuntu-latest" not in workflow, "CI must not use a floating Ubuntu runner")
    require("branches:" not in workflow, "CI push trigger must cover all branches")
    require("pull_request_target:" not in workflow, "CI must not use pull_request_target")
    action_uses = re.findall(
        r"^\s*(?:-\s*)?uses:\s*([^@\s]+)@([^\s#]+)", workflow, flags=re.MULTILINE
    )
    require(len(action_uses) == 2, "CI workflow must use exactly two approved actions")
    require(action_uses.count(("actions/checkout", CHECKOUT_ACTION.split("@", 1)[1])) == 1,
            "CI must use the approved checkout action once")
    require(action_uses.count(("actions/setup-python", SETUP_PYTHON_ACTION.split("@", 1)[1])) == 1,
            "CI must use the approved Python setup action once")
    require(workflow.count("persist-credentials: false") == 1, "CI checkout must not persist credentials")
    for action, revision in action_uses:
        require(action in ALLOWED_ACTIONS, f"CI action {action} is not approved")
        require(re.fullmatch(r"[a-f0-9]{40}", revision), f"CI action {action} must be commit-pinned")

    makefile = read_text("Makefile")
    root_declaration = "override ROOT := $(REPOSITORY_ROOT)"
    root_assignments = re.findall(
        r"^(?:override\s+)?ROOT\s*[:+?]?=", makefile, re.MULTILINE
    )
    require(
        len(root_assignments) == 1
        and makefile.splitlines().count(root_declaration) == 1
        and makefile.splitlines().count("$(PUBLIC_TARGETS): override ROOT := $(REPOSITORY_ROOT)") == 1,
        "Makefile must contain global and public-target root protection",
    )
    require(
        makefile.count("override REPOSITORY_MAKEFILE := $(lastword $(MAKEFILE_LIST))") == 1
        and makefile.count("override REPOSITORY_ROOT := $(abspath $(dir $(REPOSITORY_MAKEFILE)))") == 1,
        "Makefile must derive the root from its checked-in Makefile identity",
    )
    for contract in (
        ".PHONY: __repository-make-authority build check lint root-test test verify",
        "override PYTHON := $(value PYTHON)",
        "PYTHON must be a literal executable path, not Make syntax",
        "RUN_LEGACY_XCODE must be the literal value 0 or 1",
        "override SHELL := /bin/sh",
        "MAKEFLAGS must not be overridden for repository verification",
        "MAKEFILES must be empty; repository verification requires this Makefile to be loaded alone",
        "MAKEFILE_LIST must not be overridden",
        "root-test:",
        '"$$ROOT/scripts/test-makefile-authority.sh"',
        "test: lint",
        "verify: root-test lint test build",
        "check: verify",
        '"$$PYTHON" "$$ROOT/scripts/check_ios_project.py"',
        'cd "$$ROOT" && xcodebuild',
    ):
        require(contract in makefile, f"Makefile must support invocation outside the repository: {contract}")
    require(
        "docs/plans/2026-06-14-make-root-override-protection.md" in read_text("README.md"),
        "README.md must index Make root override protection evidence",
    )

    docs = {
        "README.md": ["GitHub Actions", "docs/plans/2026-06-10-ci-baseline.md"],
        "VISION.md": ["GitHub Actions"],
        "SECURITY.md": ["GitHub Actions", "make check"],
        "CHANGES.md": ["GitHub Actions"],
    }

    for relative_path, required_phrases in docs.items():
        text = read_text(relative_path)
        for phrase in required_phrases:
            require(phrase in text, f"{relative_path} must document {phrase}")

    makefile = read_text("Makefile")
    require("RUN_LEGACY_XCODE ?= 0" in makefile, "legacy Xcode execution must default off")
    require(
        makefile.count('[ "$(RUN_LEGACY_XCODE)" = "1" ] && command -v xcodebuild') == 2,
        "native test and build gates must require explicit legacy Xcode opt-in",
    )


def check_twitter_json_guards():
    find_tweeps = read_text("location_tracker/FindTweeps.swift")
    location = read_text("location_tracker/TweepLocation.swift")
    picture = read_text("location_tracker/TweepPicture.swift")
    view_controller = read_text("location_tracker/ViewController.swift")
    url_helper = read_text("location_tracker/URL.swift")
    twitter_response = read_text("location_tracker/TwitterResponse.swift")
    app_delegate = read_text("location_tracker/AppDelegate.swift")
    login_controller = read_text("location_tracker/LoginController.swift")
    twitter_header = read_text("TwitterKit.framework/Versions/A/Headers/TWTRAPIClient.h")

    require(
        "Called on main queue." in twitter_header,
        "vendored Twitter request callbacks must retain their documented main-queue contract",
    )

    raw_error_logs = {
        "location_tracker/FindTweeps.swift": (find_tweeps, ("connectionError", "clientError")),
        "location_tracker/TweepLocation.swift": (location, ("connectionError", "clientError")),
        "location_tracker/TweepPicture.swift": (picture, ("connectionError", "clientError")),
        "location_tracker/LoginController.swift": (login_controller, ("error",)),
    }
    for relative_path, (source, error_names) in raw_error_logs.items():
        for error_name in error_names:
            require(
                re.search(
                    rf"\b(?:print|println|NSLog)\s*\([^\n]*\b{error_name}\b",
                    source,
                )
                is None,
                f"{relative_path} must not write raw {error_name} details to logs",
            )

    for relative_path, source in (
        ("location_tracker/FindTweeps.swift", find_tweeps),
        ("location_tracker/TweepLocation.swift", location),
        ("location_tracker/TweepPicture.swift", picture),
    ):
        require(
            "ValidatedTwitterResponseData(response, data: data, error: connectionError)" in source,
            f"{relative_path} must validate Twitter response metadata before JSON parsing",
        )
        require(
            "JSONObjectWithData(responseData" in source,
            f"{relative_path} must parse only validated Twitter response data",
        )
    for contract in (
        'response?.URL?.scheme?.lowercaseString != "https"',
        "response as? NSHTTPURLResponse",
        "httpResponse!.statusCode < 200",
        "httpResponse!.statusCode >= 300",
        'mimeType != "application/json"',
        "expectedContentLength > Int64(maximumTwitterResponseBytes)",
        "data.length > maximumTwitterResponseBytes",
    ):
        require(contract in twitter_response, f"Twitter response guard is missing: {contract}")

    require(
        'json!["users"]' not in find_tweeps,
        "list-member JSON must not force-unwrap the response object",
    )
    require(
        "json as? JSONDictionary" in find_tweeps,
        "list-member JSON must guard the response dictionary",
    )
    require(
        find_tweeps.count("completion(result: [])") >= 2,
        "list-member request error paths must complete with an empty result",
    )
    require('json![0]["geo"]' not in location, "timeline JSON must not force-unwrap the first tweet")
    require(
        'geo["coordinates"]!' not in location,
        "coordinate JSON must not force-unwrap the coordinates array",
    )
    require(
        "coordinates.count >= 2" in location,
        "coordinate JSON must verify latitude and longitude are present",
    )
    require(
        "NormalizedTweepCoordinate(coordinates[1], minimum: -90, maximum: 90)" in location,
        "coordinate JSON must validate, bound, and reduce latitude precision",
    )
    require(
        "NormalizedTweepCoordinate(coordinates[0], minimum: -180, maximum: 180)" in location,
        "coordinate JSON must validate, bound, and reduce longitude precision",
    )
    require(
        "var coordinateResult = Array<Double>()" in location,
        "timeline coordinate lookup must keep an empty fallback result",
    )
    require(
        "coordinateResult = [lat, lng]" in location,
        "timeline coordinate lookup must store normalized coordinates before completion",
    )
    for contract in (
        "CFGetTypeID(number) == CFBooleanGetTypeID()",
        "isfinite(coordinate) == 0",
        "coordinate < minimum || coordinate > maximum",
        "round(coordinate * tweepCoordinatePrecision) / tweepCoordinatePrecision",
    ):
        require(contract in location, f"coordinate privacy guard is missing: {contract}")
    require(
        "completion(result: coordinateResult)" in location,
        "timeline coordinate lookup must complete after parsing succeeds or finds no coordinates",
    )
    require(
        location.count("completion(result: [])") >= 2,
        "timeline coordinate request error paths must complete with an empty result",
    )
    require(
        "if result.count < 2" in view_controller,
        "map annotations must guard malformed coordinate results before indexing",
    )
    require(
        "latitude: result[0]" in view_controller,
        "map annotations must use normalized latitude from TweepLocation result[0]",
    )
    require(
        "longitude: result[1]" in view_controller,
        "map annotations must use normalized longitude from TweepLocation result[1]",
    )
    require(
        "latitude: result[1]" not in view_controller and "longitude:result[0]" not in view_controller,
        "map annotations must not swap normalized latitude and longitude values",
    )
    require(
        "profile_image_url!" not in picture,
        "profile image JSON must not force-unwrap the profile image URL",
    )
    require(
        "if let foundProfileImageURL" in picture,
        "profile image JSON must guard the profile image URL",
    )
    require(
        'var profileImageURL = ""' in picture,
        "profile image lookup must keep an empty fallback result",
    )
    require(
        "completion(result: profileImageURL)" in picture,
        "profile image lookup must complete after parsing succeeds or finds no image URL",
    )
    require(
        picture.count('completion(result: "")') >= 2,
        "profile image request error paths must complete with an empty result",
    )
    require(
        "NSURL(string: url_string)!" not in view_controller,
        "profile image annotation URL must not be force-unwrapped",
    )
    require(
        "if let imageURL = NSURL(string: url_string)" in view_controller,
        "profile image annotation URL must be optional-guarded",
    )
    require(
        "if let newImg = image" in view_controller,
        "profile image annotation must guard decoded images",
    )
    for contract in (
        "pinView = TweepPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)",
        "pinView!.image = nil",
        "if let tweep = annotation as? TweepAnnotation",
        "if let currentAnnotation = currentPinView.annotation",
        "if currentAnnotation === annotation",
    ):
        require(contract in view_controller, f"annotation image reuse guard is missing: {contract}")
    require(
        "let tweep = annotation as TweepAnnotation" not in view_controller,
        "map annotations must not be force-cast to TweepAnnotation",
    )
    require(
        view_controller.count(
            "pinView = TweepPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)"
        )
        == 1,
        "map annotation views must only be created when dequeue returns nil",
    )
    require(
        "sleep(5)" not in view_controller,
        "map setup must not block the async completion path with sleep",
    )
    require(
        "let mapDelay = 5 * Double(NSEC_PER_SEC)" in view_controller,
        "map setup must keep the delayed map reveal explicit",
    )
    require(
        "dispatch_after(mapTime, dispatch_get_main_queue())" in view_controller,
        "map setup must reveal the map asynchronously on the main queue",
    )
    for contract in (
        "var mapRefreshGeneration = 0",
        "mapRefreshGeneration += 1",
        "let refreshGeneration = mapRefreshGeneration",
        "for existingAnnotation in mapView.annotations",
        "if !(existingAnnotation is MKUserLocation)",
        "mapView.removeAnnotation(annotationToRemove)",
        "self.locateTweep(u, refreshGeneration: refreshGeneration)",
        "func locateTweep(handle: String, refreshGeneration: Int)",
        "if let pinView = mapView.viewForAnnotation(existingAnnotation) as? TweepPinAnnotationView",
        "pinView.cancelImageRequest()",
    ):
        require(contract in view_controller, f"map refresh generation guard is missing: {contract}")
    require(
        view_controller.count("if self.mapRefreshGeneration != refreshGeneration") == 5,
        "list, location, picture, reveal, and refresh callbacks must reject stale generations",
    )
    require(
        view_controller.index("mapRefreshGeneration += 1")
        < view_controller.index("let refreshGeneration = mapRefreshGeneration")
        < view_controller.index("for existingAnnotation in mapView.annotations")
        < view_controller.index("self.refresh.hidden = true")
        < view_controller.index("FindTweeps()"),
        "map refresh ownership, annotation cleanup, and UI gating must precede asynchronous work",
    )
    require(
        view_controller.count("self.refresh.hidden = true") == 1,
        "refresh control must be hidden once at refresh start",
    )
    require(
        "func downloadImage(url: NSURL, handler: ((image: UIImage?, NSError!) -> Void)) -> NSURLSessionDataTask?" in url_helper,
        "downloadImage must expose optional decoded images",
    )
    for contract in (
        "private class TweepPinAnnotationView: MKPinAnnotationView",
        "var imageTask: NSURLSessionDataTask?",
        "var imageRequestGeneration = 0",
        "func cancelImageRequest()",
        "override func prepareForReuse()",
        "let imageTask = url.downloadImage",
        "pinView!.imageTask = imageTask",
        "imageTask?.resume()",
    ):
        require(contract in view_controller + url_helper, f"profile image cancellation guard is missing: {contract}")
    cancel_image_request = re.search(
        r"func cancelImageRequest\(\) \{(?P<body>.*?)\n    \}",
        view_controller,
        re.DOTALL,
    )
    require(cancel_image_request is not None, "pin view must centralize image request cancellation")
    cancel_body = cancel_image_request.group("body")
    for contract in (
        "imageRequestGeneration += 1",
        "imageTask?.cancel()",
        "imageTask = nil",
    ):
        require(contract in cancel_body, f"image request cancellation is missing: {contract}")
    require(
        cancel_body.index("imageRequestGeneration += 1")
        < cancel_body.index("imageTask?.cancel()")
        < cancel_body.index("imageTask = nil"),
        "image request cancellation must invalidate, cancel, then release the task",
    )
    prepare_for_reuse = re.search(
        r"override func prepareForReuse\(\) \{(?P<body>.*?)\n    \}",
        view_controller,
        re.DOTALL,
    )
    require(prepare_for_reuse is not None, "pin view must override prepareForReuse")
    prepare_body = prepare_for_reuse.group("body")
    for contract in (
        "super.prepareForReuse()",
        "cancelImageRequest()",
        "image = nil",
    ):
        require(contract in prepare_body, f"prepareForReuse cancellation is missing: {contract}")
    require(
        prepare_body.index("cancelImageRequest()") < prepare_body.index("image = nil"),
        "prepareForReuse must cancel image work before clearing the rendered image",
    )
    reassignment = re.search(
        r"if pinView == nil \{.*?\n            \}\n            else \{(?P<body>.*?)\n            \}",
        view_controller,
        re.DOTALL,
    )
    require(reassignment is not None, "annotation view reassignment block must remain explicit")
    reassignment_body = reassignment.group("body")
    for contract in (
        "pinView!.cancelImageRequest()",
        "pinView!.annotation = annotation",
    ):
        require(contract in reassignment_body, f"annotation reassignment is missing: {contract}")
    require(
        reassignment_body.index("pinView!.cancelImageRequest()")
        < reassignment_body.index("pinView!.annotation = annotation"),
        "annotation reassignment must cancel obsolete image work first",
    )
    request_start = re.search(
        r"pinView!\.imageRequestGeneration \+= 1\s+"
        r"let imageRequestGeneration = pinView!\.imageRequestGeneration\s+"
        r"let imageTask = url\.downloadImage",
        view_controller,
    )
    require(request_start is not None, "profile image requests must capture a new generation")
    completion = re.search(
        r"let imageTask = url\.downloadImage\(imageURL, \{image, error in"
        r"(?P<body>.*?)\n                    \}\)",
        view_controller,
        re.DOTALL,
    )
    require(completion is not None, "profile image completion block must remain explicit")
    completion_body = completion.group("body")
    for contract in (
        "if let currentPinView = pinView",
        "currentPinView.imageRequestGeneration == imageRequestGeneration",
        "currentPinView.imageTask = nil",
        "if let currentAnnotation = currentPinView.annotation",
        "if currentAnnotation === annotation",
        "if let newImg = image",
        "currentPinView.image = circle",
    ):
        require(contract in completion_body, f"profile image completion guard is missing: {contract}")
    require(
        completion_body.index("currentPinView.imageRequestGeneration == imageRequestGeneration")
        < completion_body.index("currentPinView.imageTask = nil")
        < completion_body.index("if currentAnnotation === annotation")
        < completion_body.index("currentPinView.image = circle"),
        "matching completion must release ownership before annotation-checked rendering",
    )
    require(
        view_controller.index("pinView!.imageTask = imageTask")
        < view_controller.index("imageTask?.resume()"),
        "pin must own the suspended image task before it starts",
    )
    for path, fragment in (
        ("README.md", "Per-pin request generations keep late cancelled callbacks"),
        ("SECURITY.md", "match the pin's active request generation"),
        ("VISION.md", "stale callbacks clear"),
        ("CHANGES.md", "matching profile-image completions"),
    ):
        require(fragment in read_text(path), f"{path} must document image request generation guards")
    require(url_helper.count("return nil") == 1, "HTTPS rejection must return one nil task")
    require(url_helper.count("return task") == 2, "image transport must return one created and one exposed task")
    require(
        url_helper.index('url.scheme?.lowercaseString != "https"')
        < url_helper.index("return nil")
        < url_helper.index("let imageRequest"),
        "non-HTTPS image URLs must return nil before request creation",
    )
    require("task.resume()" not in url_helper, "downloadImage must return a suspended task for ownership")
    require(
        "UIImage(data: data)!" not in url_helper,
        "downloadImage must not force-unwrap decoded image data",
    )
    require(
        "handler(image: nil, error)" in url_helper,
        "downloadImage must report failed image downloads without crashing",
    )
    for contract in (
        'url.scheme?.lowercaseString != "https"',
        'response.URL?.scheme?.lowercaseString != "https"',
        "maximumImageBytes = 5 * 1024 * 1024",
        "cachePolicy: .ReturnCacheDataElseLoad",
        "timeoutInterval: 15",
        "NSURLSessionDataDelegate",
        "let createdSession = NSURLSession(",
        "dataTaskWithRequest(",
        "response as? NSHTTPURLResponse",
        "httpResponse!.statusCode < 200",
        "httpResponse!.statusCode >= 300",
        'mimeType?.hasPrefix("image/") != true',
        "response.expectedContentLength > Int64(maximumImageBytes)",
        "receivedData.length + data.length > maximumImageBytes",
        "dataTask.cancel()",
        "dispatch_async(dispatch_get_main_queue())",
        'downloadError(3, description: "Profile image could not be decoded")',
    ):
        require(contract in url_helper, f"profile image transport guard is missing: {contract}")
    require(
        "NSURLConnection" not in url_helper,
        "profile image transport must not restore deprecated NSURLConnection",
    )
    require(
        url_helper.count("dispatch_async(dispatch_get_main_queue())") == 2,
        "profile image rejection and completion must return on the main queue",
    )
    require(
        "queue: NSOperationQueue.mainQueue()" not in url_helper,
        "profile image network and decode work must not run on the main operation queue",
    )
    require(
        "garethpaul-app.appspot.com" not in url_helper + app_delegate,
        "hardcoded external coordinate upload endpoint must not be present",
    )
    require(
        "func geo(" not in url_helper and ".geo(" not in app_delegate,
        "location coordinates must not be silently uploaded through URL.geo",
    )
    require(
        "func post(params" not in url_helper,
        "unused coordinate POST helper must not be kept in URL.swift",
    )
    require(
        "if session == nil || error != nil" in login_controller,
        "Twitter login must not segue when the session is missing or an error is present",
    )
    require(
        login_controller.index("if session == nil || error != nil")
        < login_controller.index('performSegueWithIdentifier("ViewController"'),
        "Twitter login failure guard must run before the segue",
    )


def check_location_log_privacy():
    app_delegate = read_text("location_tracker/AppDelegate.swift")
    view_controller = read_text("location_tracker/ViewController.swift")
    info_plist = read_text("location_tracker/Info.plist")

    require("NSLocation" not in info_plist, "app must not declare unused location permission keys")
    require(
        "CLLocationManager" not in app_delegate + view_controller,
        "app must not instantiate a device location manager",
    )

    for fragment in (
        "func displayLocationInfo",
        "containsPlacemark.locality",
        "containsPlacemark.postalCode",
        "containsPlacemark.administrativeArea",
        "containsPlacemark.country",
    ):
        require(fragment not in view_controller, f"unused placemark logging must stay removed: {fragment}")

    for fragment in (
        "import CoreLocation",
        "didUpdateToLocation",
        "newLocation.coordinate.latitude",
        "newLocation.coordinate.longitude",
    ):
        require(fragment not in app_delegate, f"unused coordinate logging must stay removed: {fragment}")


def main():
    checks = [
        check_project_manifest_references,
        check_app_plist_contract,
        check_test_plist_contract,
        check_resources_parse,
        check_docs_plans,
        check_ci_baseline_docs,
        check_twitter_json_guards,
        check_location_log_privacy,
    ]
    try:
        for check in checks:
            check()
    except (AssertionError, ET.ParseError, json.JSONDecodeError, plistlib.InvalidFileException) as exc:
        return fail(str(exc))

    print(f"TweepTracker static project checks passed ({len(checks)} checks).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
