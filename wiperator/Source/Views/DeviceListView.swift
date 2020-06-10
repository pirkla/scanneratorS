//
//  DeviceListView.swift
//  wiperator
//
//  Created by Andrew Pirkl on 5/27/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import SwiftUI

struct DeviceListView: View {
    @ObservedObject var contentViewModel: ContentViewModel
//    @Binding var listArray: [Device]
    @State private var localStorage: [Device] = []
    @State private var selected: Device? = nil
    let updateFunc: (String,String) -> Void
    
    var credentials: Credentials
    var body: some View {
        NavigationView{
            List(contentViewModel.deviceArray) { device in
                NavigationLink(destination: DeviceDetailView(device: device, credentials: self.credentials,updateFunc:self.updateFunc).onReceive(self.contentViewModel.$deviceArray) {
                    items in
                    if !items.contains(device) {
                        print("doesn'texist")
                        self.selected = nil // !!! unwind at once
                    }
                    }, tag: device, selection: self.$selected
                    )
                {
                DeviceRow(device: device, credentials: self.credentials)
                }
            }

        }
        .onReceive(contentViewModel.$deviceArray) { items  in
                DispatchQueue.main.async {
                    self.localStorage = items
            }
        }
        .onAppear {
            self.localStorage = self.contentViewModel.deviceArray // ! initial load from model
        }
    }
}

//struct DeviceListView_Previews: PreviewProvider {
//    static var previews: some View {
//        DeviceListView(credentials: Credentials(Username: "name", Password: "pass", Server: URLComponents()))
//    }
//}


struct DeviceRow: View {
    @State private var showModal = false

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
