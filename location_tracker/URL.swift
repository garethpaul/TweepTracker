//
//  URL.swift
//  location_tracker
//

import Foundation
import UIKit

private class ProfileImageDownload: NSObject, NSURLSessionDataDelegate {
    private let maximumImageBytes: Int
    private let handler: ((image: UIImage?, NSError!) -> Void)
    private let receivedData = NSMutableData()
    private var acceptedResponse = false
    private var terminalError: NSError?
    private var session: NSURLSession?
    private var finished = false

    init(maximumImageBytes: Int, handler: ((image: UIImage?, NSError!) -> Void)) {
        self.maximumImageBytes = maximumImageBytes
        self.handler = handler
    }

    private func downloadError(code: Int, description: String) -> NSError {
        return NSError(
            domain: "com.garethpaul.TweepTracker.ImageDownload",
            code: code,
            userInfo: [NSLocalizedDescriptionKey: description]
        )
    }

    func taskWithRequest(imageRequest: NSURLRequest) -> NSURLSessionDataTask {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.requestCachePolicy = .ReturnCacheDataElseLoad
        let createdSession = NSURLSession(
            configuration: configuration,
            delegate: self,
            delegateQueue: nil
        )
        session = createdSession
        let task = createdSession.dataTaskWithRequest(imageRequest)
        return task
    }

    func URLSession(
        session: NSURLSession,
        dataTask: NSURLSessionDataTask,
        didReceiveResponse response: NSURLResponse,
        completionHandler: (NSURLSessionResponseDisposition) -> Void
    ) {
        let httpResponse = response as? NSHTTPURLResponse
        let mimeType = response.MIMEType?.lowercaseString
        if response.URL?.scheme?.lowercaseString != "https" ||
            httpResponse == nil || httpResponse!.statusCode < 200 ||
            httpResponse!.statusCode >= 300 || mimeType?.hasPrefix("image/") != true ||
            response.expectedContentLength > Int64(maximumImageBytes) {
            terminalError = downloadError(2, description: "Invalid profile image response")
            completionHandler(.Cancel)
            return
        }

        acceptedResponse = true
        completionHandler(.Allow)
    }

    func URLSession(
        session: NSURLSession,
        dataTask: NSURLSessionDataTask,
        didReceiveData data: NSData
    ) {
        if receivedData.length + data.length > maximumImageBytes {
            terminalError = downloadError(2, description: "Profile image exceeds size limit")
            dataTask.cancel()
            return
        }

        receivedData.appendData(data)
    }

    func URLSession(
        session: NSURLSession,
        task: NSURLSessionTask,
        didCompleteWithError error: NSError?
    ) {
        if let responseError = terminalError {
            finish(image: nil, error: responseError)
            return
        }
        if error != nil || !acceptedResponse {
            finish(image: nil, error: error)
            return
        }

        let image = UIImage(data: receivedData)
        finish(
            image: image,
            error: image == nil ? downloadError(3, description: "Profile image could not be decoded") : nil
        )
    }

    private func finish(image: UIImage?, error: NSError?) {
        if finished {
            return
        }
        finished = true

        let completedSession = session
        session = nil
        completedSession?.finishTasksAndInvalidate()
        dispatch_async(dispatch_get_main_queue()) {
            self.handler(image: image, error)
        }
    }
}

class URL {
    private let maximumImageBytes = 5 * 1024 * 1024

    func downloadImage(url: NSURL, handler: ((image: UIImage?, NSError!) -> Void)) -> NSURLSessionDataTask?
    {
        if url.scheme?.lowercaseString != "https" {
            let error = NSError(
                domain: "com.garethpaul.TweepTracker.ImageDownload",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Profile images must use HTTPS"]
            )
            dispatch_async(dispatch_get_main_queue()) {
                handler(image: nil, error)
            }
            return nil
        }

        let imageRequest = NSURLRequest(
            URL: url,
            cachePolicy: .ReturnCacheDataElseLoad,
            timeoutInterval: 15
        )
        let download = ProfileImageDownload(
            maximumImageBytes: maximumImageBytes,
            handler: handler
        )
        let task = download.taskWithRequest(imageRequest)
        return task
    }
}
