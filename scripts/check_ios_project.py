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


def check_app_plist_contract():
    info = load_plist("location_tracker/Info.plist")
    require(info["CFBundlePackageType"] == "APPL", "app bundle package type must be APPL")
    require(info["CFBundleExecutable"] == "$(EXECUTABLE_NAME)", "app executable must use Xcode substitution")
    require(info["UIMainStoryboardFile"] == "Storyboard", "app must launch the bundled Storyboard.storyboard")
    require(info["UILaunchStoryboardName"] == "LaunchScreen", "app must keep the launch screen reference")
    require("_" not in info["CFBundleIdentifier"], "bundle identifier must not contain underscores")


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

    plans = sorted(plan_dir.glob("*.md"))
    require(plans, "docs/plans must contain completed maintenance plans")

    for plan in plans:
        text = plan.read_text(encoding="utf-8")
        require("status: completed" in text.lower(), f"{plan.name} must be completed")
        require("make check" in text, f"{plan.name} must document make check verification")


def check_twitter_json_guards():
    find_tweeps = read_text("location_tracker/FindTweeps.swift")
    location = read_text("location_tracker/TweepLocation.swift")
    picture = read_text("location_tracker/TweepPicture.swift")
    view_controller = read_text("location_tracker/ViewController.swift")
    url_helper = read_text("location_tracker/URL.swift")
    app_delegate = read_text("location_tracker/AppDelegate.swift")
    login_controller = read_text("location_tracker/LoginController.swift")

    require(
        'json!["users"]' not in find_tweeps,
        "list-member JSON must not force-unwrap the response object",
    )
    require(
        "json as? JSONDictionary" in find_tweeps,
        "list-member JSON must guard the response dictionary",
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
        "if let profileImageURL" in picture,
        "profile image JSON must guard the profile image URL",
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
    require(
        "func downloadImage(url: NSURL, handler: ((image: UIImage?, NSError!) -> Void))" in url_helper,
        "downloadImage must expose optional decoded images",
    )
    require(
        "UIImage(data: data)!" not in url_helper,
        "downloadImage must not force-unwrap decoded image data",
    )
    require(
        "handler(image: nil, error)" in url_helper,
        "downloadImage must report failed image downloads without crashing",
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


def main():
    checks = [
        check_project_manifest_references,
        check_app_plist_contract,
        check_test_plist_contract,
        check_resources_parse,
        check_docs_plans,
        check_twitter_json_guards,
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
