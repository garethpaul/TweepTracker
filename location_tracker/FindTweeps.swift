//
//  FindPictures.swift
//

import Foundation
import TwitterKit

func FindTweeps(completion: (result: [String]) -> Void) {

    typealias JSON = AnyObject
    typealias JSONDictionary = Dictionary<String, JSON>
    typealias JSONArray = Array<JSON>

    let statusesShowEndpoint = "https://api.twitter.com/1.1/lists/members.json"
    let params = ["slug": "twitter-dev-advocates", "owner_screen_name": "twitterdev"]
    var clientError : NSError?
    Twitter.initialize()
    let completed = false

    Twitter.sharedInstance().logInWithCompletion{
        (session, error) -> Void in
        if (session != nil) {
            //println("signed in as \(session.userName)");
            /// go
            let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod("GET", URL:  statusesShowEndpoint, parameters: params, error:&clientError)

            if request != nil {
                println("request is not nil")
                Twitter.sharedInstance().APIClient.sendTwitterRequest(request) {
                    (response, data, connectionError) -> Void in
                    if (connectionError == nil) {
                        var jsonError : NSError?
                        let json : AnyObject? =
                        NSJSONSerialization.JSONObjectWithData(data,
                            options: nil,
                            error: &jsonError)

                        // users
                        var userArray = Array<String>()
                        if let users = json!["users"] as? JSONArray {
                               for user in users {
                                if let screenName = user["screen_name"] as?String {
                                    userArray.append(screenName)
                                }
                            }
                        }
                        // manually add some
                        userArray.append("jcipriano")
                        userArray.append("joncipriano")
                        userArray.append("davelester")
                        userArray.append("lfcipriani")
                        userArray.append("ktopenn")
                        userArray.append("logicalarthur")
                        userArray.append("laurenschutte")
                        userArray.append("beardigsit")
                        userArray.append("noonisms")
                        userArray.append("isaach")
                        completion(result: userArray)
                    }

                    else {
                        println("Error: \(connectionError)")
                    }
                }
            }
            else {
                println("Error: \(clientError)")
            }

        } else {
            println("error: \(error.localizedDescription)");
        }
        
    }
}




