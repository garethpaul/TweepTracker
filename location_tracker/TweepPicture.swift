//
//  TweepPicture//  location_tracker
//

import Foundation
import TwitterKit

func TweepPicture(handle: String, completion: (result: String) -> Void) {

    typealias JSON = AnyObject
    typealias JSONDictionary = Dictionary<String, JSON>
    typealias JSONArray = Array<JSON>

    let statusesShowEndpoint = "https://api.twitter.com/1.1/users/show.json"
    let params = ["screen_name": handle]
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
                        let profile_image_url = json!["profile_image_url"] as? String
                        completion(result: String(profile_image_url!))
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



