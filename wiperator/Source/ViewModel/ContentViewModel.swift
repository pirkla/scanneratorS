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

    var credentials: Credentials = Credentials(Username: "", Password: "", Server: URLComponents())
    var searchTask: URLSessionDataTask?
    
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
    
    @Published var showSheet = true
    
    @Published var errorDescription: String = "Unknown" {
        willSet {
            activeSheet = .errorView
        }
    }
    
    @Published var assetTag: String = "" {
        willSet(newValue){
            SearchBetter(searchValue: newValue)
        }
    }
    @Published var deviceArray = Array<Device>()
        
    var searchModelArray = [ SearchModel(title:"Serial Number", value: "serialnumber"),
                             SearchModel(title:"Asset Tag", value: "assettag")
    ]
    var searchIndex = 0
    
    public func DeviceSearch(searchType: String, search: String, completion: @escaping (Result<[Device], Error>) -> Void)-> URLSessionDataTask?{
        let queryArray = [URLQueryItem(name: searchType,value: search)]
        return Device.AllDevicesRequest(baseURL: self.credentials.Server, filters: queryArray, credentials: self.credentials.BasicCreds, session: URLSession.shared) {
            (result) in
            switch result {
            case .success(let allDevices):
                completion(.success(allDevices.devices))
            case .failure(let error):
                completion(.failure(error))
                print(error)
            }
        }
    }
    
    public func UpdateNotes(udid: String, notes: String, completion: @escaping (Result<JSResponse,Error>)->Void) {
        _ = DeviceUpdateRequest(udid: udid, notes: notes).submitDeviceUpdate(baseUrl: credentials.Server, credentials: credentials.BasicCreds, session: URLSession.shared){
            (result) in
            switch result {
            case .success(let response):
                #if targetEnvironment(macCatalyst)
                self.SearchBetter(searchValue: self.assetTag)
                #endif
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
                print(error)
                //todo: handle non-200 response in jssresponse (maybe up the line a step) - why is that even a thing?
                self.errorDescription = error.localizedDescription
            }
        }
    }
    
    public func SearchBetter(searchValue: String) {
        searchTask?.cancel()
        searchTask = DeviceSearch(searchType: self.searchModelArray[self.searchIndex].value, search: searchValue){
            [weak self]
            (result) in
            switch result {
            case .success(let devices):
                DispatchQueue.main.async {
                    self?.deviceArray = devices
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.deviceArray = Array<Device>()
                    print(error)
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
                    self.deviceArray = devices
                }
            })
        
        case .scanner:
            return AnyView(CodeScannerView(codeTypes: [.qr,.aztec,.code128,.code39,.code39Mod43,.code93,.dataMatrix,.ean13,.ean8,.interleaved2of5,.itf14,.pdf417,.upce], simulatedData: "testdata") {
                result in
                self.showSheet = false
                switch result {
                case .success(let code):
                    self.assetTag = code
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
