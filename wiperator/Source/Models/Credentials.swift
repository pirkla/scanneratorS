//
//  Credentials.swift
//  wiperator
//
//  Created by Andrew Pirkl on 5/31/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation

struct Credentials {
    var Username: String
    var Password: String
    var Server: String
    var BasicCreds : String {
        get {
            return String("\(Username):\(Password)").toBase64()
        }
    }
}
