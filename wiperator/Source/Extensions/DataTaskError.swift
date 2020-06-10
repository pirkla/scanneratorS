//
//  DataTaskError.swift
//  wiperator
//
//  Created by Andrew Pirkl on 6/8/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation

public enum DataTaskError: Error {
    case emptyData
    case requestFailure(description: String,statusCode: Int)
    case unknown
}

extension DataTaskError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyData:
            return "No data found"
        case .requestFailure(let description, let statusCode):
            return "Request failed due to error: \(description). Status Code: \(statusCode)"
        default:
            return "Unknown"
        }
    }
}
