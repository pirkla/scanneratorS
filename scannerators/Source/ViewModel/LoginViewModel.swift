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
    @Published var serverError = ""
    @Published var loggingIn = false
    
    var credentials: Credentials {
        get {
            return Credentials(Username: networkID, Password: apiKey, Server: baseURL)
        }
    }
    
    @Published var saveCredentials = true

    func loadCredentials() {
        saveCredentials = UserDefaults.standard.bool(forKey: "shouldSaveCredentials")
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
        UserDefaults.standard.set(saveCredentials, forKey: "shouldSaveCredentials")
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
    
    public func deviceSearch(completion: @escaping (Result<[Device], Error>) -> Void)-> URLSessionDataTask?{
        let dataTask = Device.allDevicesRequest(baseURL: baseURL, credentials: credentials.BasicCreds, session: URLSession.shared) {(result) in
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
    
    public func login(completion: @escaping (Credentials,[Device])->Void) {
        loggingIn = true
        _ = deviceSearch() {
            [weak self]
            result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let devices):
                completion(self.credentials,devices)
                DispatchQueue.main.async {
                    self.loggingIn = false
                }
                do {
                    try self.syncronizeCredentials()
                }
                catch {
                    print("Failed to save credentials with error: \(error)")
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.serverError = "Failed to log in\n \(error.localizedDescription)"
                    print(error)
                    self.loggingIn = false
                }
            }
        }
    }
}
