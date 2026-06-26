//
//  FindTweeps.swift
//

import Foundation
import TwitterKit

func NormalizedTweepHandles(handles: [String]) -> [String] {
    let invalidCharacters = NSCharacterSet(
        charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"
    ).invertedSet
    var normalizedHandles = Array<String>()
    var seenHandles = Set<String>()

    for candidateHandle in handles {
        let handle = candidateHandle.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
        if handle.isEmpty || handle.characters.count > 15 ||
            handle.rangeOfCharacterFromSet(invalidCharacters) != nil {
            continue
        }

        let comparisonHandle = handle.lowercaseString
        if seenHandles.contains(comparisonHandle) {
            continue
        }

        seenHandles.insert(comparisonHandle)
        normalizedHandles.append(handle)
    }

    return normalizedHandles
}

func NormalizedSupplementalTweepHandles(value: AnyObject?) -> [String] {
    guard let configuredHandles = value as? [String] else {
        return []
    }

    return NormalizedTweepHandles(configuredHandles)
}

func FindTweeps(completion: (result: [String]) -> Void) {

    typealias JSON = AnyObject
    typealias JSONDictionary = Dictionary<String, JSON>
    typealias JSONArray = Array<JSON>

    // We must get the memebers of the list.
    // As a pointer ou can find the members of via :- https://twitter.com/TwitterDev/lists/twitter-dev-advocates
    // Documentation on this endpoint can be found via :- https://dev.twitter.com/rest/reference/get/lists/members
    //

    // Setup endpoint URL
    let memberListAPI = "https://api.twitter.com/1.1/lists/members.json"

    // Setup Params to be sent to the endpoint.
    let params = ["slug": "twitter-dev-advocates", "owner_screen_name": "twitterdev"]

    // Setup a catch for errors.
    var clientError : NSError?

    // initialize Twitter
    Twitter.initialize()

    // Create a request to the API notice "GET", "URL" params.
    let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod("GET", URL:  memberListAPI, parameters: params, error:&clientError)

    // We only want to do things when the request is not nill
    if request != nil {

        // The API call is ready to send.
        Twitter.sharedInstance().APIClient.sendTwitterRequest(request) {
            (response, data, connectionError) -> Void in

            if let responseData = ValidatedTwitterResponseData(response, data: data, error: connectionError) {
                var jsonError : NSError?
                let json : AnyObject? = NSJSONSerialization.JSONObjectWithData(responseData, options: nil, error: &jsonError)

                // userArray this is how we store all the users to send back to the ViewController.
                var userArray = Array<String>()

                // get the output from the json {"users": [...]}
                if let jsonObject = json as? JSONDictionary {
                    if let users = jsonObject["users"] as? JSONArray {

                        // iterate through the list of users
                        for user in users {

                            // if there is a json object like the following {"screen_name": "gpj"}
                            if let screenName = user["screen_name"] as?String {

                                // Append the user the array
                                userArray.append(screenName)
                            }
                        }
                    }
                }

                let configuredSupplementalHandles = NSBundle.mainBundle().objectForInfoDictionaryKey(
                    "SupplementalTwitterHandles"
                )
                userArray.appendContentsOf(
                    NormalizedSupplementalTweepHandles(configuredSupplementalHandles)
                )

                // On completed send the userArray back to the ViewController.
                completion(result: NormalizedTweepHandles(userArray))
            }

            else {
                completion(result: [])
            }
        }
    }
    else {
        completion(result: [])
    }

}

