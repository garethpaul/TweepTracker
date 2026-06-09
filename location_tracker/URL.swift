//
//  URL.swift
//  location_tracker
//

import Foundation
import UIKit

class URL{

    func downloadImage(url: NSURL, handler: ((image: UIImage?, NSError!) -> Void))
    {
        var imageRequest: NSURLRequest = NSURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(imageRequest,
            queue: NSOperationQueue.mainQueue(),
            completionHandler:{response, data, error in
                if error != nil || data == nil {
                    handler(image: nil, error)
                    return
                }
                handler(image: UIImage(data: data), error)
        })
    }
}
