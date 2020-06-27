//
//  Credentials.swift
//  wiperator
//
//  Created by Andrew Pirkl on 5/31/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation

struct Credentials {
    var username: String
    var password: String
    var server: URLComponents
    var basicCreds : String {
        get {
            return String("\(username):\(password)").toBase64()
        }
    }
}

extension Credentials {
    static func saveCredentials(networkID: String, apiKey: String, server: String) throws {
        try! removeCredentials(server: server, networkID: networkID)
        let password = apiKey.data(using: String.Encoding.utf8)!
        let query: [String:Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server,
            kSecAttrAccount as String: networkID,
            kSecValueData as String: password
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.couldNotAddKeychain(description: SecCopyErrorMessageString(status,nil))
        }

    }

    static func removeCredentials(server: String, networkID: String) throws {
        let query = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server,
            kSecAttrAccount as String: networkID
        ] as CFDictionary
        let status = SecItemDelete(query)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.couldNotRemoveKeychain(description: SecCopyErrorMessageString(status,nil)) }
    }

    static func loadCredentials(server: String) throws -> (networkID: String, apiKey: String) {
        let query: [String:Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        
        guard let existingItem = item as? [String : Any],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8),
            let account = existingItem[kSecAttrAccount as String] as? String
        else {
            throw KeychainError.unexpectedPasswordData
        }
        return (networkID: account,apiKey: password)
    }
}
