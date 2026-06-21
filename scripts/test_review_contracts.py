#!/usr/bin/env python3

from pathlib import Path
import subprocess


ROOT = Path(__file__).resolve().parents[1]


def read(relative_path):
    return (ROOT / relative_path).read_text(encoding="utf-8")


def require(condition, message):
    if not condition:
        raise AssertionError(message)


def test_twitter_response_boundary():
    response = read("location_tracker/TwitterResponse.swift")
    for contract in (
        'response?.URL?.scheme?.lowercaseString != "https"',
        "response as? NSHTTPURLResponse",
        "httpResponse!.statusCode < 200",
        "httpResponse!.statusCode >= 300",
        'mimeType != "application/json"',
        "expectedContentLength > Int64(maximumTwitterResponseBytes)",
        "data.length > maximumTwitterResponseBytes",
    ):
        require(contract in response, f"missing Twitter response contract: {contract}")

    for relative_path in (
        "location_tracker/FindTweeps.swift",
        "location_tracker/TweepLocation.swift",
        "location_tracker/TweepPicture.swift",
    ):
        source = read(relative_path)
        require(
            "ValidatedTwitterResponseData(response, data: data, error: connectionError)" in source,
            f"{relative_path} must validate Twitter response metadata before JSON parsing",
        )


def test_coordinate_privacy_boundary():
    source = read("location_tracker/TweepLocation.swift")
    for contract in (
        "CFGetTypeID(number) == CFBooleanGetTypeID()",
        "isfinite(coordinate) == 0",
        "coordinate < minimum || coordinate > maximum",
        "round(coordinate * tweepCoordinatePrecision) / tweepCoordinatePrecision",
        "NormalizedTweepCoordinate(coordinates[1], minimum: -90, maximum: 90)",
        "NormalizedTweepCoordinate(coordinates[0], minimum: -180, maximum: 180)",
    ):
        require(contract in source, f"missing coordinate privacy contract: {contract}")


def test_bounded_profile_image_transport():
    source = read("location_tracker/URL.swift")
    for contract in (
        "NSURLSessionDataDelegate",
        "didReceiveResponse response: NSURLResponse",
        "response.expectedContentLength > Int64(maximumImageBytes)",
        "didReceiveData data: NSData",
        "receivedData.length + data.length > maximumImageBytes",
        "dataTask.cancel()",
        "let task = createdSession.dataTaskWithRequest(imageRequest)",
    ):
        require(contract in source, f"missing bounded image transport contract: {contract}")
    require(
        "dataTaskWithRequest(\n            imageRequest,\n            completionHandler:" not in source,
        "profile images must not be fully buffered by a completion-handler data task",
    )


def test_image_task_ownership_and_refresh_cancellation():
    source = read("location_tracker/ViewController.swift")
    assignment = "pinView!.imageTask = imageTask"
    resume = "imageTask?.resume()"
    require(assignment in source, "pin must own the suspended task before it starts")
    require(resume in source, "pin image task must be explicitly resumed")
    require(source.index(assignment) < source.index(resume), "task ownership must precede resume")
    require(
        "if let pinView = mapView.viewForAnnotation(existingAnnotation) as? TweepPinAnnotationView"
        in source,
        "refresh must find visible pin views before removing annotations",
    )
    require(
        "pinView.cancelImageRequest()" in source,
        "refresh must cancel visible pin image tasks",
    )


def test_permission_and_callback_queue_boundaries():
    plist = read("location_tracker/Info.plist")
    app_sources = "\n".join(
        read(path)
        for path in (
            "location_tracker/AppDelegate.swift",
            "location_tracker/ViewController.swift",
        )
    )
    require("NSLocation" not in plist, "app must not declare unused device-location permission keys")
    require("CLLocationManager" not in app_sources, "app must not instantiate a device location manager")
    header = read("TwitterKit.framework/Versions/A/Headers/TWTRAPIClient.h")
    require("Called on main queue." in header, "vendored Twitter callback queue contract changed")


def test_legacy_xcode_is_explicitly_opt_in():
    makefile = read("Makefile")
    readme = read("README.md")
    require("RUN_LEGACY_XCODE ?= 0" in makefile, "legacy Xcode execution must default off")
    require(
        makefile.count('[ "$(RUN_LEGACY_XCODE)" = "1" ] && command -v xcodebuild') == 2,
        "test and build must both require explicit legacy Xcode opt-in",
    )
    require(
        "RUN_LEGACY_XCODE=1 make check" in readme,
        "README must document the explicit historical toolchain gate",
    )


def test_historical_credential_response():
    project = read("location_tracker.xcodeproj/project.pbxproj")
    security = read("SECURITY.md")
    require("PBXShellScriptBuildPhase" not in project, "credential-bearing Fabric build phase returned")
    require(
        "both historical Fabric credentials" in security,
        "security guidance must explicitly require provider-side revocation of both credentials",
    )


def test_generated_finder_metadata_is_excluded():
    tracked_files = subprocess.run(
        ["git", "-C", str(ROOT), "ls-files"],
        check=True,
        stdout=subprocess.PIPE,
        text=True,
    )
    finder_metadata = sorted(
        path for path in tracked_files.stdout.splitlines() if Path(path).name == ".DS_Store"
    )
    require(
        not finder_metadata,
        f"generated Finder metadata must not be tracked: {', '.join(finder_metadata)}",
    )
    finder_paths = (".DS_Store", "location_tracker/Images.xcassets/.DS_Store")

    def ignored_paths():
        return {
            path: subprocess.run(
                ["git", "-C", str(ROOT), "check-ignore", "--no-index", "--quiet", "--", path],
                check=False,
            ).returncode
            == 0
            for path in finder_paths
        }

    require(
        all(ignored_paths().values()),
        ".gitignore must effectively exclude root and nested Finder metadata",
    )

    gitignore = ROOT / ".gitignore"
    original_gitignore = gitignore.read_text(encoding="utf-8")
    try:
        gitignore.write_text(
            original_gitignore + "\n!.DS_Store\n!**/.DS_Store\n",
            encoding="utf-8",
        )
        require(
            not all(ignored_paths().values()),
            "Finder metadata ignore contract must detect later negation rules",
        )
    finally:
        gitignore.write_text(original_gitignore, encoding="utf-8")


def test_hostile_mutations_are_rejected():
    mutations = (
        (
            "location_tracker/TweepLocation.swift",
            "CFGetTypeID(number) == CFBooleanGetTypeID()",
            "false",
        ),
        (
            "location_tracker/TwitterResponse.swift",
            "httpResponse!.statusCode >= 300",
            "httpResponse!.statusCode >= 600",
        ),
        (
            "location_tracker/URL.swift",
            "receivedData.length + data.length > maximumImageBytes",
            "receivedData.length + data.length < maximumImageBytes",
        ),
        (
            "location_tracker/ViewController.swift",
            "pinView!.imageTask = imageTask",
            "pinView!.imageTask = nil",
        ),
        (
            "location_tracker/ViewController.swift",
            "pinView.cancelImageRequest()",
            "pinView.image = nil",
        ),
        (
            "location_tracker.xcodeproj/project.pbxproj",
            "/* End PBXBuildFile section */",
            "PBXShellScriptBuildPhase\n/* End PBXBuildFile section */",
        ),
    )

    checker = ROOT / "scripts/check_ios_project.py"
    for relative_path, original, replacement in mutations:
        path = ROOT / relative_path
        source = path.read_text(encoding="utf-8")
        require(source.count(original) == 1, f"mutation anchor changed: {relative_path}: {original}")
        try:
            path.write_text(source.replace(original, replacement, 1), encoding="utf-8")
            result = subprocess.run(
                ["python3", str(checker)],
                cwd=ROOT,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
            )
            require(result.returncode != 0, f"checker accepted hostile mutation in {relative_path}")
        finally:
            path.write_text(source, encoding="utf-8")


def main():
    tests = [value for name, value in sorted(globals().items()) if name.startswith("test_")]
    for test in tests:
        test()
    print(f"TweepTracker review contracts passed ({len(tests)} tests).")


if __name__ == "__main__":
    main()
