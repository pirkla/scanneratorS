//
//  ContentViewModel.swift
//  wiperator
//
//  Created by Andrew Pirkl on 5/27/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation
import AVFoundation

class ContentViewModel: ObservableObject{
//    var credentials: Credentials = Credent ials()
    
    @Published var networkID: String = ""
    @Published var apiKey: String = ""
    public var basicCreds : String {
        get {
            return String("\(networkID):\(apiKey)").toBase64()
        }
    }
    
    @Published var enteredURL: String = "" {
        willSet(newValue){
            baseURL = URLBuilder.BuildURL(baseURL: newValue)
        }
    }
    
    var baseURL: URLComponents = URLComponents()

    @Published var assetTag: String = "" {
        willSet(newValue){
            print(newValue)
            DeviceSearch(searchType: self.searchModelArray[self.searchIndex].value, search: newValue){
                [weak self]
                (result) in
                switch result {
                case .success(let devices):
                    DispatchQueue.main.async {
                        self?.deviceArray = devices
                        print(devices)
                    }

                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.deviceArray = Array<Device>()
                        print(error)
                    }
                }
            }
        }
    }
    
    @Published var deviceArray = Array<Device>()
    
    @Published var saveCredentials = true
    
    var searchModelArray = [ SearchModel(title:"Serial Number", value: "serialnumber"),
                             SearchModel(title:"Asset Tag", value: "assettag")
    ]
    @Published var searchIndex = 0
    
    public func DeviceSearch(searchType: String, search: String, completion: @escaping (Result<[Device], Error>) -> Void){
        let queryArray = [URLQueryItem(name: searchType,value: search)]
        Device.AllDevicesRequest(baseURL: baseURL, filters: queryArray, credentials: basicCreds, session: URLSession.shared) {(result) in
            switch result {
            case .success(let allDevices):
                completion(.success(allDevices.devices))
            case .failure(let error):
                completion(.failure(error))
                print(error)
            }
        }
    }
    
//    public func ReadConfig(){
//        if let managedConf = UserDefaults.standard.object(forKey: "com.apple.configuration.managed") as? [String:Any?] {
//            if let myServerURL = managedConf["serverURL"] as? String{
//                self.enteredURL = myServerURL
//            }
//            if let myNetworkID = managedConf["networkID"] as? String{
//                self.networkID = myNetworkID
//            }
//            if let myApiKey = managedConf["apiKey"] as? String{
//                self.apiKey = myApiKey
//            }
//        }
//        if let myServerURL = Bundle.main.object(forInfoDictionaryKey: "serverURL") as? String {
//            self.enteredURL = myServerURL
//        }
//        if let myNetworkID = Bundle.main.object(forInfoDictionaryKey: "networkID") as? String {
//            self.networkID = myNetworkID
//        }
//        if let myApiKey = Bundle.main.object(forInfoDictionaryKey: "apiKey") as? String {
//            self.apiKey = myApiKey
//        }
//    }
    
    func loadCredentials() {
        enteredURL = UserDefaults.standard.string(forKey: "jamfSchoolServer") ?? enteredURL
        do {
            let credentials = try SecurityWrapper.loadCredentials(server: enteredURL)
            networkID = credentials.networkID
            apiKey = credentials.apiKey
        }
        catch {
            print("Error loading credentials: \(error)")
        }
    }
    
    func syncronizeCredentials() throws{
        if saveCredentials {
            UserDefaults.standard.set(enteredURL, forKey: "jamfSchoolServer")
            do {
                try SecurityWrapper.saveCredentials(networkID: networkID, apiKey: apiKey, server: enteredURL)
                }
            catch {
                print("failed to save credentials with error: \(error)")
            }
        }
        else {
            do {
                try SecurityWrapper.removeCredentials(server: enteredURL, networkID: networkID)
            }
        }
    }
    
    func checkCameraAccess(completion: @escaping (Bool)->Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: // The user has previously granted access to the camera.
                completion(true)
            default: // The user has not yet been asked for camera access.
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
}
