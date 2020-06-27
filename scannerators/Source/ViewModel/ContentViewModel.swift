//
//  ContentViewModel.swift
//  wiperator
//
//  Created by Andrew Pirkl on 5/27/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation
import AVFoundation
import SwiftUI


class ContentViewModel: ObservableObject{
    // set the number of devices that can show in the navigation list view - if hundreds/thousands are returned rendering the list is problematic
    private var maxDevices = 100
    
    var credentials: Credentials = Credentials(username: "", password: "", server: URLComponents())
    
    // publish if sheet modal should show - used to show login & error description sheets
    @Published var showSheet = true
    
    // publish if an http request is taking place - used to control the loading icon
    @Published var isLoading = false
    
    // typing and lookupText together handle if a lookup sould be made
    // calculate if the search field is currently being typed in or not. If yes then no then run a search
    private var typing: Int = 0 {
        willSet(newValue) {
            if newValue == 0 {
                searchHandler(searchValue: lookupText)
            }
        }
    }
    // receive input from lookup bar and incrememnt typing as changed, then after a slight delay decrement
    @Published var lookupText: String = "" {
        willSet {
            self.typing += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.typing -= 1
            }
        }
    }

    // projected and wrapped value used to make deviceArray published but only for a limited number of devices. If the number of devices published is too high rendering is problematic. Calculated with maxDevices
    @Published private(set) var projectedDeviceArray = Array<Device>()
    private(set) var wrappedDeviceArray: Array<Device> {
        get {
            return projectedDeviceArray
        }
        set(newValue) {
            DispatchQueue.main.async {
                self.projectedDeviceArray = (newValue.count > self.maxDevices) ? Array(newValue.dropLast(newValue.count - self.maxDevices)) : newValue
            }
        }
    }
    
    // used to store the full list of devices since projectedDeviceArray only stores a limited number
    var fullDeviceList = Array<Device>()
    
    // store time of last request to get all devices so we can make sure we only do it once every x seconds. todo:Could make this prettier
    var lastDeviceCheck = Date()
    
    enum ActiveSheet {
       case login, scanner, errorView
    }
    
    // when the active sheet is set set showsheet to true to display newly chosen sheet
    var activeSheet: ActiveSheet = .login {
        willSet {
            DispatchQueue.main.async {
                self.showSheet = true
            }
        }
    }
    
    // when an error description is set set active sheet to show the error view with the new description
    private var errorDescription: String = "Unknown" {
        willSet {
            activeSheet = .errorView
        }
    }
    
    // if given credentials assume a managed app config was used, don't open the login view, and run a device search
    init(credentials: Credentials?) {
        guard let myCredentials = credentials else {
            self.activeSheet = .login            
            return
        }
        self.credentials = myCredentials
        self.showSheet = false
        _ = deviceSearch() {
            [weak self]
            (result) in
            switch result {
            case .success(let allDevices):
                self?.wrappedDeviceArray = allDevices
            case .failure(let error):
                self?.errorDescription = error.localizedDescription
                print(error)
            }
        }
    }
    
    
    func setErrorDescription(_ description: String){
        DispatchQueue.main.async {
            self.errorDescription = description
        }
    }
    
    func setIsLoading(_ isLoading: Bool){
        DispatchQueue.main.async {
            self.isLoading = isLoading
        }
    }
    
    /**
     Request all devices from JS
     */
    public func deviceSearch(completion: @escaping (Result<[Device], Error>) -> Void)-> URLSessionDataTask?{
        let dataTask = Device.allDevicesRequest(baseURL: credentials.server, credentials: credentials.basicCreds, session: URLSession.shared) {
            (result) in
            switch result {
            case .success(let allDevices):
                completion(.success(allDevices.devices))
            case .failure(let error):
                completion(.failure(error))
                print(error)
            }
        }
        dataTask?.resume()
        return dataTask
    }
    
    /**
     Filter all devices by a searchvalue
     */
    private func deviceFilter(searchValue: String){
        guard (DateInterval(start: lastDeviceCheck, end: Date()).duration > 100) else {
            guard (searchValue.count > 0) else {
                self.wrappedDeviceArray = fullDeviceList
                return
            }
            let filteredArray = fullDeviceList.filter {
                device in
                ((device.fullname?.range(of: searchValue, options: .caseInsensitive) != nil) ||
                    (device.name?.range(of: searchValue, options: .caseInsensitive) != nil) ||
                    (device.assetTag?.range(of: searchValue, options: .caseInsensitive) != nil) ||
                    (device.serialNumber?.range(of: searchValue, options: .caseInsensitive) != nil)
                )
            }
            self.wrappedDeviceArray = filteredArray
            return
        }
    }
        
    /**
     Request all devices  and filter them for a search if last check time > 10 seconds, otherwise filter only
     */
    private func searchHandler(searchValue: String) {
        guard (DateInterval(start: lastDeviceCheck, end: Date()).duration > 10) else {
            deviceFilter(searchValue: searchValue)
            return
        }
        setIsLoading(true)
        _ = Device.allDevicesRequest(baseURL: credentials.server, credentials: credentials.basicCreds, session: URLSession.shared) {
            [weak self]
            (result) in
            self?.setIsLoading(false)
            switch result {
            case .success(let allDevices):
                self?.lastDeviceCheck = Date()
                self?.fullDeviceList = allDevices.devices
                self?.deviceFilter(searchValue: searchValue)
            case .failure(let error):
                self?.errorDescription = error.localizedDescription
                print(error)
            }
        }
        
    }

    func checkCameraAccess(completion: @escaping (Bool)->Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                completion(true)
            default:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        completion(true)
                    }
                    else {
                        completion(false)
                    }
                }
        }
    }
    
    // calculate which modal should be showing when showModal is true
    func currentModal() -> AnyView {
        switch activeSheet {
        case .login:
            return AnyView(LoginView() {
                (credentials,devices) in
                self.credentials = credentials
                DispatchQueue.main.async {
                    self.fullDeviceList = devices
                    self.wrappedDeviceArray = devices
                }
            })
        
        case .scanner:
            return AnyView(CodeScannerView(codeTypes: [.qr,.aztec,.code128,.code39,.code39Mod43,.code93,.dataMatrix,.ean13,.ean8,.interleaved2of5,.itf14,.pdf417,.upce], simulatedData: "testdata") {
                result in
                self.showSheet = false
                switch result {
                case .success(let code):
                    self.lookupText = code
                case .failure(let error):
                    self.errorDescription = error.localizedDescription
                    print(error.localizedDescription)
                }
            })
        case .errorView:
            return AnyView(InfoSheetView(title: "An error occurred", description: self.errorDescription, image: Image(systemName: "exclamationmark.octagon.fill")))
        }
    }
}
