//
//  DeviceDetailViewModel.swift
//  wiperator
//
//  Created by Andrew Pirkl on 6/10/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation

class DeviceDetailViewModel {
    var credentials: Credentials?
    @Published var device: Device?
    var updateFunc: ((String,String) -> Void)?
}
