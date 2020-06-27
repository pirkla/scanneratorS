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
    // access function to set loading in parent view which changes the behavior of the loading icon
    var setIsLoading: (Bool) -> Void
    // access function to set error description which will pop up error sheet in parent view
    var setErrorDescription: (String) -> Void

    var body: some View {
            List(deviceArray) { device in
                NavigationLink(destination: DeviceDetailView(deviceDetailViewModel: DeviceDetailViewModel(device: device, credentials: self.credentials, setIsLoading: self.setIsLoading, setErrorDescription: self.setErrorDescription)))
                {
                DeviceRow(device: device)
                }
            }
    }
}

struct DeviceRow: View {
    var device: Device
    
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
        DeviceRow(device: Device())
    }
}
