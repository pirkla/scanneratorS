//
//  DeviceDetailViewModel.swift
//  Scannerator S
//
//  Created by Andrew Pirkl on 6/19/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation
import SwiftUI

class DeviceDetailViewModel: ObservableObject {
    
    @Published var showModal = false
    @Published var device: Device
    let credentials: Credentials
    var setIsLoading: (Bool) -> Void
    var setErrorDescription: (String) -> Void
    
    init(device: Device, credentials: Credentials, setIsLoading: @escaping (Bool)->Void, setErrorDescription: @escaping (String)->Void) {
        self.device = device
        self.credentials = credentials
        self.setIsLoading = setIsLoading
        self.setErrorDescription = setErrorDescription
    }
    
    // update current device - used when checkin is changed
    func updateDevice() {
        setIsLoading(true)
        _ = Device.deviceRequest(baseURL: credentials.Server, udid: device.UDID ?? "", credentials: credentials.BasicCreds, session: URLSession.shared){
            result in
            self.setIsLoading(false)
            switch result {
            case .success(let deviceResponse):
                DispatchQueue.main.async {
                    self.device = deviceResponse.device
                }
            case .failure(let error):
                self.setErrorDescription(error.localizedDescription)
                print(error)
            }
        }
    }
    
    func wipeDevice() {
        setIsLoading(true)
        _ = WipeRequest(udid: self.device.UDID, clearActivationLock: "true").submitWipeRequest(baseURL: self.credentials.Server, credentials: self.credentials.BasicCreds, session: URLSession.shared) {
            result in
            self.setIsLoading(false)
            switch result {
            case .success(let jsResponse):
                print(jsResponse)
            case .failure(let error):
                print(error)
                self.setErrorDescription(error.localizedDescription)

            }
        }
    }
    
    // calculate which text and image should be shown for checkin status
    func checkinStatusView() -> AnyView{
        var imageString = "questionmark.circle"
        var textString = device.notes ?? "Unkown"
        
        if let isCheckedIn = device.isCheckedIn {
            if isCheckedIn {
                imageString = "tray.and.arrow.down.fill"
                textString = "Checked In"
            }
            else {
                imageString = "tray.and.arrow.up.fill"
                textString = "Checked Out"
            }
        }
        return AnyView(
            HStack {
                Text("Checkin Status: ").frame(width: 180, alignment: .trailing)
                HStack {
                Image(systemName: imageString)
                Text(textString)
                }.frame(width: 180, alignment: .leading)
            }
        )
    }
    
    public func updateNotes(notes: String) {
        setIsLoading(true)
        _ = DeviceUpdateRequest(udid: self.device.UDID, notes: notes).submitDeviceUpdate(baseUrl: credentials.Server, credentials: credentials.BasicCreds, session: URLSession.shared){
            [weak self]
            (result) in
            guard let self = self else {
                return
            }
            self.setIsLoading(false)
            switch result {
            case .success(_):
                self.updateDevice()
            case .failure(let error):
                print(error)
                self.setErrorDescription(error.localizedDescription)
            }
        }
    }
    
    // calculate which checkin button should show
    func checkedInView() -> AnyView?{
        // checkin
        let checkInbutton = Button(action: {
            guard let notes = self.device.notes else {
                return
            }
            let newNote = notes.replacingOccurrences(of: "Checked In", with: "",options: .caseInsensitive).replacingOccurrences(of: "Checked Out", with: "",options: .caseInsensitive) + "Checked In"
            self.updateNotes(notes: newNote)
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
        
        //checkout
        let checkOutButton = Button(action: {
            guard let notes = self.device.notes else {
                return
            }
            let newNote = notes.replacingOccurrences(of: "Checked In", with: "",options: .caseInsensitive).replacingOccurrences(of: "Checked Out", with: "",options: .caseInsensitive) + "Checked Out"
            self.updateNotes(notes: newNote)
            
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

        guard let isCheckedIn = device.isCheckedIn else {
            return AnyView(VStack {
                checkOutButton
                checkInbutton
            })
        }
        
        //calculation
        if isCheckedIn {
            return AnyView(checkOutButton)
        }
        else {
            return AnyView(checkInbutton)
        }
    }
    
    // calculate if wipe button should show - it should only show for iOS
    func wipeView(_ showModal: Binding<Bool>) -> AnyView? {
        if !device.isiOS {
            return nil
        }
        return AnyView(Button(action: {
            self.showModal = true
        }) {
            HStack {
                Image(systemName: "trash")
                    .padding([.top, .leading, .bottom], 10.0)
                Text("Wipe Device")
                    .padding([.top, .bottom, .trailing], 10.0)
            }
            .background(Color.init("TextBackground"))
        }.sheet(isPresented: showModal) {
            OptionSheet(title: "Wiping: \(self.device.name ?? "Unknown")", description: "Are you sure?") { choice in
                if choice {
                    self.wipeDevice()
                }
            }
        }
        .cornerRadius(10)
        )
    }
    
    //calculate the url for use with the device name button
    func deviceUrl() -> URL? {
        guard let udid = device.UDID else { return nil }
        var urlComponents = credentials.Server
        urlComponents.path = "/devices/details/\(udid)/device-list.html"
        return urlComponents.url
    }
}
