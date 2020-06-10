//
//  DeleteDeviceView.swift
//  wiperator
//
//  Created by Andrew Pirkl on 5/27/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import SwiftUI

struct WipeDeviceView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let title: String
    let description: String
    let device: Device
    let credentials: Credentials
//    let baseUrl: URLComponents
//    let credentials: String
//    let icon = Image("CFBundlePrimaryIcon")

    var body: some View {
      Group {
        Text(title)
        Text(description)
        VStack {
            Button(action: {
                _ = WipeRequest(udid: self.device.UDID, clearActivationLock: "true").submitWipeRequest(baseURL: self.credentials.Server, credentials: self.credentials.BasicCreds, session: URLSession.shared) {
                    _ in
                }
               self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "checkmark")
                        .padding([.top, .leading, .bottom], 10.0)
                    Text("Yes")
                        .padding([.top, .bottom, .trailing], 10.0)
                }
                .background(Color.init("TextBackground"))
            }
            .cornerRadius(10)
            
            Button(action: {
               self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "xmark")
                        .padding([.top, .leading, .bottom], 10.0)
                    Text("Cancel")
                        .padding([.top, .bottom, .trailing], 10.0)
                }
                .background(Color.init("TextBackground"))
              
            }
            .cornerRadius(10)
        }
      }
    }
}

struct WipeDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        WipeDeviceView(title: "Preview", description: "Description Preview", device: Device(), credentials:Credentials(Username: "", Password: "", Server: URLComponents()))
    }
}