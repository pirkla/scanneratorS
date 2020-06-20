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
    var setIsLoading: (Bool) -> Void
    var setErrorDescription: (String) -> Void

    var body: some View {
            List(deviceArray) { device in
                NavigationLink(destination: DeviceDetailView(deviceDetailViewModel: DeviceDetailViewModel(device: device, credentials: self.credentials, setIsLoading: self.setIsLoading, setErrorDescription: self.setErrorDescription)))
                {
                DeviceRow(device: device, credentials: self.credentials)
                }
            }
    }
}

//struct DeviceListView_Previews: PreviewProvider {
//    static var previews: some View {
//        DeviceListView(deviceArray: [Device](), credentials: Credentials(Username: "", Password: "", Server: URLComponents()))
//    }
//}


struct DeviceRow: View {
    var device: Device
    var credentials: Credentials
    
    var body: some View {
        HStack {
            DeviceImage(device.isiOS)
            Text(device.name ?? "")
            Text(device.assetTag ?? "")
        }
    }
    func DeviceImage(_ isiOS: Bool) -> AnyView {
        if isiOS {
            return AnyView(Image(systemName: "rectangle")
                .rotationEffect(Angle(degrees: 90)))
        }
        else {
            return AnyView(Image(systemName: "desktopcomputer"))
        }
    }

}

struct DeviceRow_Previews: PreviewProvider {
    static var previews: some View {
        DeviceRow(device: Device(), credentials: Credentials(Username: "", Password: "", Server: URLComponents()))
    }
}
