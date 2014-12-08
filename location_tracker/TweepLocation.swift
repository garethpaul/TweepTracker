//
//  TweepLocation.swift
//

import Foundation
import TwitterKit

func TweepLocation(handle: String, completion: (result: [Double]) -> Void) {

    // setup type alias for common types found in JSON API responses.
    typealias JSON = AnyObject
    typealias JSONDictionary = Dictionary<String, JSON>
    typealias JSONArray = Array<JSON>

    // setup the endpoint
    let urlEndpoint = "https://api.twitter.com/1.1/statuses/user_timeline.json"

    // setup params to send with the request to the endpoint
    let params = ["screen_name": handle]

    // setup holder for errors
    var clientError : NSError?

    // initialize twitter
    Twitter.initialize()

    // begin creating the request
    let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod("GET", URL:  urlEndpoint, parameters: params, error:&clientError)

    if request != nil {

        // send the request to those people at Twitter.
        Twitter.sharedInstance().APIClient.sendTwitterRequest(request) {
                (response, data, connectionError) -> Void in
                if (connectionError == nil) {

                    var jsonError : NSError?

                    // setup json to contain the data
                    let json : AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError)

                    // find the key "geo" from the Tweets
                    let last_tweet = json![0]["geo"]

                    // if the geo is not nil e.g. not empty
                    if last_tweet != nil {

                        // see if the json_object is an array
                        if let json_object = json as? JSONArray {

                            // for each item in the json_object
                            for item in json_object{

                                // check whether it is a dictionary
                                if let json_dict = item as? JSONDictionary {

                                    // if geo is not null
                                    if json_dict["geo"] != nil {

                                        if let geo = json_dict["geo"] as? JSONDictionary{

                                            // handle the coordinates
                                            if let coordinates = geo["coordinates"] as? NSArray{
                                                var lat: AnyObject = geo["coordinates"]![1]
                                                var lng: AnyObject = geo["coordinates"]![0]

                                                let r = [Double(lat.doubleValue), Double(lng.doubleValue)]

                                                // send the coordinate data to completion
                                                completion(result: r)

                                                // don't continue to iterate one geo is fine for us
                                                break
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                }
                else {
                    println("Error: \(connectionError)")
                }
        }
    }
    else {
        println("Error: \(clientError)")
    }



        }




