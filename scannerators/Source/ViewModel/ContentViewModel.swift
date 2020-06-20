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
    private var maxDevices = 100
    
    var credentials: Credentials = Credentials(Username: "", Password: "", Server: URLComponents())
    
    
    var searchTask: [URLSessionDataTask]?
    @Published var showSheet = true
    
    @Published var isLoading = false
    
    private var typing: Int = 0 {
        willSet(newValue) {
            if newValue == 0 {
                searchHandler(searchValue: lookupText)
            }
        }
    }
    
    @Published var lookupText: String = "" {
        willSet {
            self.typing += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.typing -= 1
            }
        }
    }

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
    
    enum ActiveSheet {
       case login, scanner, errorView
    }
    var activeSheet: ActiveSheet = .login {
        willSet {
            DispatchQueue.main.async {
                self.showSheet = true
            }
        }
    }
    
    private var errorDescription: String = "Unknown" {
        willSet {
            activeSheet = .errorView
        }
    }
    
    
    init(credentials: Credentials?) {
        guard let myCredentials = credentials else {
            self.showSheet = true
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
    
    public func deviceSearch(completion: @escaping (Result<[Device], Error>) -> Void)-> URLSessionDataTask?{
        let dataTask = Device.allDevicesRequest(baseURL: credentials.Server, credentials: credentials.BasicCreds, session: URLSession.shared) {
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
        
    private func searchHandler(searchValue: String) {
        searchTask?.forEach { $0.cancel() }
        setIsLoading(true)
        _ = Device.broadSearchRequest(baseURL: credentials.Server, searchValue: searchValue, credentials: credentials.BasicCreds, session: URLSession.shared) {
            [weak self]
            result in
            self?.setIsLoading(false)
            switch result {
            case .success(let devices):
                DispatchQueue.main.async {
                    self?.wrappedDeviceArray = devices
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.wrappedDeviceArray = Array<Device>()
                    print(error)
                }
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
    
    func currentModal() -> AnyView {
        switch activeSheet {
        case .login:
            return AnyView(LoginView() {
                (credentials,devices) in
                self.credentials = credentials
                DispatchQueue.main.async {
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
