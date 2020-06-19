//
//  JSResponse.swift
//  wiperator
//
//  Created by Andrew Pirkl on 6/7/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation

struct JSResponse: Codable {
    var code: Int?
    var message: String?
    var device: String?
}
