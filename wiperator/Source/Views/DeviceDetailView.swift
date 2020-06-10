//
//  DeviceDetailView.swift
//  wiperator
//
//  Created by Andrew Pirkl on 6/7/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import SwiftUI

struct DeviceDetailView: View {

    @State var showModal = false
    let device: Device
    let credentials: Credentials
    
    let updateFunc: (String,String) -> Void

    var body: some View {
      Group {
        VStack {
            Text(device.name ?? "")
            Text(device.serialNumber ?? "")
            Text(device.assetTag ?? "")
        }
        HStack() {
            Button(action: {
                self.showModal = true
            }) {
                HStack {
                    Image(systemName: "trash")
                        .padding([.top, .leading, .bottom], 10.0)
                    Text("Wipe Device")
                        .padding([.top, .bottom, .trailing], 10.0)
                }
                .background(Color.init("TextBackground"))
            }.sheet(isPresented: self.$showModal) {
                WipeDeviceView(title: "Wiping: \(self.device.name ?? "unknown")", description: "Are you sure?", device: self.device, credentials: self.credentials)
            }
            .cornerRadius(10)
            CheckedInButton(isCheckedIn: device.isCheckedIn)
        }
      }
    }
    
    func CheckedInButton(isCheckedIn: Bool)-> AnyView{
        if isCheckedIn {
            return AnyView(CheckInButtonView(device: self.device, credentials: self.credentials, updateFunc: self.updateFunc))
        }
        else {
            return AnyView(CheckoutButtonView(device: self.device, credentials: self.credentials, updateFunc: self.updateFunc))
        }
    }
    
    func CheckArray() {
        
    }
}

struct CheckInButtonView: View {
    let device: Device
    let credentials: Credentials
    let updateFunc: (String,String) -> Void
    var body: some View {
        Button(action: {
            self.updateFunc(self.device.UDID ?? "","Checked Out")
        }) {
            HStack {
                Image(systemName: "rectangle.badge.xmark")
                    .padding([.top, .leading, .bottom], 10.0)
                Text("Check Out")
                    .padding([.top, .bottom, .trailing], 10.0)
            }
                .background(Color.init("TextBackground"))
        }
            .cornerRadius(10)
    }
}

struct CheckoutButtonView: View {
    let device: Device
    let credentials: Credentials
    let updateFunc: (String,String) -> Void
    var body: some View {
        HStack() {
            Button(action: {
                self.updateFunc(self.device.UDID ?? "","Checked In")
            }) {
                HStack {
                    Image(systemName: "rectangle.badge.checkmark")
                        .padding([.top, .leading, .bottom], 10.0)
                    Text("Check In")
                        .padding([.top, .bottom, .trailing], 10.0)
                }
                .background(Color.init("TextBackground"))
            }
            .cornerRadius(10)
        }
    }
}

//struct DeviceDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DeviceDetailView(title: "Preview", description: "Description Preview", device: Device(), credentials:Credentials(Username: "", Password: "", Server: URLComponents()), updateFunc: ("stuff","stuff")->Void)
//    }
//}
