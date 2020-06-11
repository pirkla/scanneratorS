//
//  DeviceListView.swift
//  wiperator
//
//  Created by Andrew Pirkl on 5/27/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import SwiftUI

struct DeviceListView: View {
    var deviceArray: [Device]
    var credentials: Credentials
    let updateFunc: ((String, String, @escaping (Result<JSResponse, Error>) -> Void) -> ())?

    var body: some View {
            List(deviceArray) { device in
                NavigationLink(destination: DeviceDetailView(device: device, credentials: self.credentials,updateFunc:self.updateFunc))
                {
                DeviceRow(device: device, credentials: self.credentials)
                }
            }
    }
}

struct DeviceListView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceListView(deviceArray: [Device](), credentials: Credentials(Username: "", Password: "", Server: URLComponents()), updateFunc: nil)
    }
}


struct DeviceRow: View {
    var device: Device
    var credentials: Credentials
    
    var body: some View {
        HStack {
            CheckedInImage(isCheckedIn: device.isCheckedIn)
            Text(device.name ?? "")
            Text(device.assetTag ?? "")
        }
    }
    func CheckedInImage(isCheckedIn: Bool) -> Image {
        if isCheckedIn {
            return Image(systemName: "tray.and.arrow.down.fill")
        }
        else {
            return Image(systemName: "tray.and.arrow.up.fill")
        }
    }

}

struct DeviceRow_Previews: PreviewProvider {
    static var previews: some View {
        DeviceRow(device: Device(), credentials: Credentials(Username: "", Password: "", Server: URLComponents()))
    }
}
