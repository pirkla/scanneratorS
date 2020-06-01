//
//  DeleteDeviceView.swift
//  wiperator
//
//  Created by Andrew Pirkl on 5/27/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import SwiftUI

struct DeleteDeviceView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let title: String
    let description: String
    let device: Device
    let baseUrl: URLComponents
    let credentials: String
//    let icon = Image("CFBundlePrimaryIcon")

    var body: some View {
      Group {
        Text(title)
        Text(description)
        Button(action: {
            let wipeRequest = WipeRequestModel(udid: self.device.UDID, clearActivationLock: "true")
            WipeRequestModel.SubmitWipeRequest(baseURL: self.baseUrl, credentials: self.credentials, wipeRequestModel: wipeRequest, session: URLSession.shared) {
                _ in
            }
           self.presentationMode.wrappedValue.dismiss()
        }) {
          Text("Yes")
        }
        Button(action: {
           self.presentationMode.wrappedValue.dismiss()
        }) {
          Text("No")
        }
      }
    }
}

struct DeleteDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteDeviceView(title: "Preview", description: "Description Preview", device: Device(), baseUrl: URLComponents(), credentials: "")
    }
}
