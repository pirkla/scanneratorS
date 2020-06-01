//
//  DeviceListView.swift
//  wiperator
//
//  Created by Andrew Pirkl on 5/27/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import SwiftUI

struct DeviceListView: View {
    var listArray: [Device] = []
    var baseUrl: URLComponents
    var credentials: String
    
    var body: some View {
        List(listArray) { device in
            DeviceRow(device: device, baseUrl: self.baseUrl, credentials: self.credentials)
        }
    }
}

struct DeviceListView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceListView(baseUrl: URLComponents(), credentials: "")
    }
}


struct DeviceRow: View {
    @State private var showModal = false

    var device: Device
    var baseUrl: URLComponents
    var credentials: String
    
    var body: some View {
        HStack {
            Text(device.name ?? "")
            Text(device.assetTag ?? "")
            Button(action: {
                self.showModal = true
            }) {
                Text("Show modal")
            }.sheet(isPresented: self.$showModal) {
                DeleteDeviceView(title: "Wiping device \(self.device.name ?? "unknown")", description: "Are you sure you?", device: self.device, baseUrl: self.baseUrl, credentials: self.credentials)
            }
        }
    }
}

struct DeviceRow_Previews: PreviewProvider {
    static var previews: some View {
        DeviceRow(device: Device(), baseUrl: URLComponents(), credentials: "")
    }
}
