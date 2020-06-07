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
    public var basicCreds : String {
        get {
            return String("\(networkID):\(apiKey)").toBase64()
        }
    }
    
    @Published var enteredURL: String = ""
    
    var credentials: Credentials {
        get {
            return Credentials(Username: networkID, Password: apiKey, Server: enteredURL)
        }
    }
    
//    var baseURL: URLComponents = URLComponents()
    @Published var saveCredentials = true

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
    
}
