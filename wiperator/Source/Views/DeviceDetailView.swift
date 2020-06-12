//
//  DeviceDetailView.swift
//  wiperator
//
//  Created by Andrew Pirkl on 6/7/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//
// ugh todo: cleanup and split up responsibilities
import SwiftUI

struct DeviceDetailView: View {

    @State var showModal = false
    @State var device: Device
    let credentials: Credentials
    
    let updateFunc: ((String, String, @escaping (Result<JSResponse, Error>) -> Void) -> ())?

    var body: some View {
      VStack {
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
                OptionSheet(title: "Wiping: \(self.device.name ?? "Unknown")", description: "Are you sure?") { choice in
                    if choice {
                    _ = WipeRequest(udid: self.device.UDID, clearActivationLock: "true").submitWipeRequest(baseURL: self.credentials.Server, credentials: self.credentials.BasicCreds, session: URLSession.shared) {
                        _ in
                    }
                    }
                }
            }
            .cornerRadius(10)

            
            if !device.isCheckedIn {
            Button(action: {
                if let updateFunc = self.updateFunc {
                    updateFunc(self.device.UDID ?? "","Checked In") {_ in
                        self.updateDevice()
                    }

                }
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
            else {
                Button(action: {
                    if let updateFunc = self.updateFunc {
                        updateFunc(self.device.UDID ?? "","Checked Out") {_ in
                            
                            self.updateDevice()
                        }
                    }
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
        Spacer()
      }
    }
    func updateDevice() {
        Device.DeviceRequest(baseURL: credentials.Server, udid: device.UDID ?? "", credentials: credentials.BasicCreds, session: URLSession.shared){
            result in
            switch result {
            case .success(let deviceResponse):
                self.device = deviceResponse.device
            case .failure(let error):
                print(error)
            }
        }
    }
}

struct DeviceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceDetailView(device: Device(), credentials:Credentials(Username: "", Password: "", Server: URLComponents()), updateFunc: nil)
    }
}
