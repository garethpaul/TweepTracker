//
//  URL.swift
//  location_tracker
//

import Foundation
import UIKit

class URL{

    private let maximumImageBytes = 5 * 1024 * 1024

    private func downloadError(code: Int, description: String) -> NSError {
        return NSError(
            domain: "com.garethpaul.TweepTracker.ImageDownload",
            code: code,
            userInfo: [NSLocalizedDescriptionKey: description]
        )
    }

    func downloadImage(url: NSURL, handler: ((image: UIImage?, NSError!) -> Void))
    {
        if url.scheme?.lowercaseString != "https" {
            handler(image: nil, downloadError(1, description: "Profile images must use HTTPS"))
            return
        }

        let imageRequest = NSURLRequest(
            URL: url,
            cachePolicy: .ReturnCacheDataElseLoad,
            timeoutInterval: 15
        )
        NSURLConnection.sendAsynchronousRequest(imageRequest,
            queue: NSOperationQueue(),
            completionHandler:{response, data, error in
                if error != nil || data == nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        handler(image: nil, error)
                    }
                    return
                }

                let httpResponse = response as? NSHTTPURLResponse
                let mimeType = response?.MIMEType?.lowercaseString
                if response?.URL?.scheme?.lowercaseString != "https" ||
                    httpResponse == nil || httpResponse!.statusCode < 200 ||
                    httpResponse!.statusCode >= 300 || mimeType?.hasPrefix("image/") != true ||
                    data.length > self.maximumImageBytes {
                    let responseError = self.downloadError(2, description: "Invalid profile image response")
                    dispatch_async(dispatch_get_main_queue()) {
                        handler(image: nil, responseError)
                    }
                    return
                }

                let image = UIImage(data: data)
                dispatch_async(dispatch_get_main_queue()) {
                    handler(image: image, image == nil ?
                        self.downloadError(3, description: "Profile image could not be decoded") : nil)
                }
        })
    }
}
