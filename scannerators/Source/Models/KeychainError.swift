//
//  KeychainError.swift
//  wiperator
//
//  Created by Andrew Pirkl on 5/30/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation

public enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
    case couldNotRemoveKeychain(description: CFString?)
    case couldNotAddKeychain(description: CFString?)
}

extension KeychainError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noPassword:
            return "No password found"
        case .unexpectedPasswordData:
            return "Unexpected password data found"
        case .unhandledError(status: let status):
            return "An unknown error ocurred \(status)"
        case .couldNotRemoveKeychain(let description):
            return "Could not remove keychain item. Error: \(description ?? "Unknown" as CFString)"
        case .couldNotAddKeychain(let description):
            return "Could not add keychain item. Error: \(description ?? "Unknown" as CFString)"
        }
    }
}
