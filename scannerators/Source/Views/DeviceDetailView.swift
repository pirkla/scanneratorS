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

    @ObservedObject var deviceDetailViewModel : DeviceDetailViewModel
    
    var body: some View {
      VStack {
        VStack {
            Text(deviceDetailViewModel.device.name ?? "")
            Text(deviceDetailViewModel.device.serialNumber ?? "")
            Text(deviceDetailViewModel.device.assetTag ?? "")
            
        }
        HStack() {
            deviceDetailViewModel.wipeView($deviceDetailViewModel.showModal)
            deviceDetailViewModel.checkedInView()
        }
        Spacer()
      }
    }
}
//
//struct DeviceDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DeviceDetailView(device: Device(), credentials:Credentials(Username: "", Password: "", Server: URLComponents()), updateFunc: nil)
//    }
//}
