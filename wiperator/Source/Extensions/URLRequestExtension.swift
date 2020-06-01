//
//  URLRequestExtension.swift
//  LicenseUnborker
//
//  Created by Andrew Pirkl on 3/13/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation

/**
 HTTP method options for requests
 */
public enum HTTPMethod: String {
    case get = "get"
    case put = "put"
    case post = "post"
    case delete = "delete"
}
/**
 Content type strings for requests
 */
public enum ContentType: String{
    case json = "application/json"
    case xml = "text/xml"
    case form = "application/x-www-form-urlencoded"
}
/**
 Authentication types for requests
 */
public enum AuthType: String{
    case basic = "Basic"
    case bearer = "Bearer"
}


/**
 Build a request without authentication
 */
extension URLRequest{
    init(url:URL, method: HTTPMethod,dataToSubmit:Data?=nil,contentType:ContentType?=nil,accept:ContentType?=nil)
    {
        self.init(url:url)
        self.httpMethod = method.rawValue
        if let contentType = contentType {
            self.addValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        }
        if let accept = accept {
            self.addValue(accept.rawValue, forHTTPHeaderField: "Accept")
        }
        if let dataToSubmit = dataToSubmit{
            self.httpBody = dataToSubmit
        }
    }
    
    
    /**
     Build a request using basic authentication
     */
    init(url:URL,basicCredentials:String,method: HTTPMethod,dataToSubmit:Data?=nil,contentType:ContentType?=nil,accept:ContentType?=nil)
    {
        self.init(url:url,method:method,dataToSubmit:dataToSubmit,contentType:contentType,accept:accept)
        self.addValue("Basic \(basicCredentials)", forHTTPHeaderField: "Authorization")
    }
    /**
     Build a request using a bearer token for authorization
     */
    init(url:URL,token:String,method: HTTPMethod,dataToSubmit:Data?=nil,contentType:ContentType?=nil,accept:ContentType?=nil)
    {
        self.init(url:url,method:method,dataToSubmit:dataToSubmit,contentType:contentType,accept:accept)
        self.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}
