//
//  LoginView.swift
//  wiperator
//
//  Created by Andrew Pirkl on 5/31/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    @State private var showLogin = true

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var loginViewModel = LoginViewModel()
    var completion: (Credentials) -> Void
    init(completion: @escaping (Credentials)->Void) {
        self.completion = completion
    }
    
    var body: some View {
        VStack() {
            HStack(){
                Text("URL")
                    .multilineTextAlignment(.leading)
                    .frame(width: 200.0, alignment: .trailing)
                HStack {
                TextField("https://sample.jamfcloud.com", text: $loginViewModel.enteredURL)
                    .textContentType(.URL)
                }
                .frame(width: 350.0, height: 22.0)
                .background(Color.init("TextBackground"))
            }
            HStack() {
                Text("Network ID")
                    .frame(width: 200.0, alignment: .trailing)
                HStack {
                    TextField("", text: $loginViewModel.networkID)
                }.frame(width: 350.0, height: 22.0)
                .background(Color.init("TextBackground"))
            }
            HStack() {
                Text("API Key")
                    .multilineTextAlignment(.leading)
                    .frame(width: 200.0, alignment: .trailing)
                HStack {
                SecureField("", text:  $loginViewModel.apiKey)
                }
                .frame(width: 350.0, height: 22.0)
                .background(Color.init("TextBackground"))
            }
            HStack {
                Button(action: {
                    self.loginViewModel.loadCredentials()
                }) {
                    Text("Load")
                }
                Button(action: {
                    self.completion(Credentials(Username: "stuff", Password: "pass", Server: "server"))
                    print("finish it")
                    self.presentationMode.wrappedValue.dismiss()
                    do {
                        try self.loginViewModel.syncronizeCredentials()
                    }
                    catch {
                        print("Failed to save credentials with error: \(error)")
                    }
                }) {
                    Text("Test Connection")
                }
                .fixedSize()
                .background(Color.init("TextBackground"))
            }
        }
        .sheet(isPresented: self.$showLogin) {
            LoginView() {
                (credentials) in
                print(credentials)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView() {
            (credentials) in
        }
    }
}
