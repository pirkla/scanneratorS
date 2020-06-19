//
//  URLBuilder.swift
//  LocationShmocation
//
//  Created by Andrew Pirkl on 5/19/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation

class URLBuilder {
    
    /**
     Create a url from someone's messed up string
     
     - returns:
     A concatenated url
     
     - parameters:
        - baseURL: The base url of the instance. Ex: manage.zuludesk.com
        - endpoint: The endpoint to be used.
        - identifierType: The type of identifier to be used.
        - identifier: The identifier to be used.
     */
    static func BuildURL(baseURL: String) -> URLComponents
    {
        let myURL = baseURL.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "http://", with: "")
        var components = URLComponents()
        components.scheme = "https"
        components.host = myURL
        return components
    }
}
