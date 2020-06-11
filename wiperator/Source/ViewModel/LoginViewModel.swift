//
//  LoginViewModel.swift
//  wiperator
//
//  Created by Andrew Pirkl on 5/31/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var networkID: String = ""
    @Published var apiKey: String = ""
    @Published var enteredURL: String = "" {
        willSet(newValue){
            baseURL = URLBuilder.BuildURL(baseURL: newValue)
        }
    }
    var baseURL: URLComponents = URLComponents()
    
    var credentials: Credentials {
        get {
            return Credentials(Username: networkID, Password: apiKey, Server: baseURL)
        }
    }
    
    @Published var saveCredentials = true

    func loadCredentials() {
        enteredURL = UserDefaults.standard.string(forKey: "jamfSchoolServer") ?? enteredURL
        do {
            let credentials = try Credentials.loadCredentials(server: enteredURL)
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
                try Credentials.saveCredentials(networkID: networkID, apiKey: apiKey, server: enteredURL)
                }
            catch {
                print("failed to save credentials with error: \(error)")
            }
        }
        else {
            do {
                try Credentials.removeCredentials(server: enteredURL, networkID: networkID)
            }
        }
    }
    
    public func DeviceSearch(completion: @escaping (Result<[Device], Error>) -> Void)-> URLSessionDataTask?{
        return Device.AllDevicesRequest(baseURL: baseURL, credentials: credentials.BasicCreds, session: URLSession.shared) {(result) in
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
    
}
