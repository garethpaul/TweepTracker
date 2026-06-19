//
//  TwitterResponse.swift
//  location_tracker
//

import Foundation

private let maximumTwitterResponseBytes = 2 * 1024 * 1024

func ValidatedTwitterResponseData(
    response: NSURLResponse!,
    data: NSData!,
    error: NSError!
) -> NSData? {
    if error != nil || data == nil {
        return nil
    }

    let httpResponse = response as? NSHTTPURLResponse
    let mimeType = response?.MIMEType?.lowercaseString
    if response?.URL?.scheme?.lowercaseString != "https" ||
        httpResponse == nil || httpResponse!.statusCode < 200 ||
        httpResponse!.statusCode >= 300 ||
        (mimeType != "application/json" && mimeType != "text/json") {
        return nil
    }

    if let expectedContentLength = response?.expectedContentLength {
        if expectedContentLength > Int64(maximumTwitterResponseBytes) {
            return nil
        }
    }
    if data.length > maximumTwitterResponseBytes {
        return nil
    }

    return data
}
