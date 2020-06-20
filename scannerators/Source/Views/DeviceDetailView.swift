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
            Button(action: {
                guard let myUrl = self.deviceDetailViewModel.deviceUrl() else {
                    self.deviceDetailViewModel.setErrorDescription("Could not find url")
                    return
                }
                UIApplication.shared.open(myUrl)
            }) {
                HStack {
                    Text(deviceDetailViewModel.device.name ?? "").font(.title)
                }.padding(.all, 7.0)
            }
            .frame(alignment: .trailing)
            .background(Color.init("TextBackground"))
            .cornerRadius(10)
            .shadow(color:.black, radius: 3,x: 1, y: 1)

            Text(deviceDetailViewModel.device.serialNumber ?? " ")
                .font(.headline)
                .padding(.top, 5)
            Text(deviceDetailViewModel.device.assetTag ?? " ")
                .padding(.bottom, 15.0)
            
            deviceDetailViewModel.checkinStatusView().padding(.bottom, 20.0)
            
        }
        HStack() {
            deviceDetailViewModel.wipeView($deviceDetailViewModel.showModal)
                .shadow(color:.black, radius: 3,x: 1, y: 1)
            deviceDetailViewModel.checkedInView()
                .shadow(color:.black, radius: 3,x: 1, y: 1)
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
