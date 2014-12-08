//
//  TweepLocation.swift
//

import Foundation
import TwitterKit

func TweepLocation(handle: String, completion: (result: [Double]) -> Void) {

    typealias JSON = AnyObject
    typealias JSONDictionary = Dictionary<String, JSON>
    typealias JSONArray = Array<JSON>

    let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/user_timeline.json"
    let params = ["screen_name": handle]
    var clientError : NSError?
    Twitter.initialize()
    let completed = false
            let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod("GET", URL:  statusesShowEndpoint, parameters: params, error:&clientError)

            if request != nil {
                println("request is not nil")
                Twitter.sharedInstance().APIClient.sendTwitterRequest(request) {
                        (response, data, connectionError) -> Void in
                        if (connectionError == nil) {
                            //println("there is no connection error")
                            var jsonError : NSError?
                            let json : AnyObject? =
                            NSJSONSerialization.JSONObjectWithData(data,
                                options: nil,
                                error: &jsonError)
                            let last_tweet = json![0]["geo"]
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
                                                    //println(geo)
                                                    if let coordinates = geo["coordinates"] as? NSArray{
                                                        var lat: AnyObject = geo["coordinates"]![1]
                                                        var lng: AnyObject = geo["coordinates"]![0]

                                                        let r = [Double(lat.doubleValue), Double(lng.doubleValue)]
                                                        completion(result: r)
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




