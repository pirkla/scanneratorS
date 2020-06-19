//
//  LoginView.swift
//  wiperator
//
//  Created by Andrew Pirkl on 5/31/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import SwiftUI

struct LoginView: View {
//    @State private var serverError = ""
//    @State private var loggingIn = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var loginViewModel = LoginViewModel()
    var completion: (Credentials,[Device]) -> Void
    init(completion: @escaping (Credentials,[Device])->Void) {
        self.completion = completion
    }
    
    var body: some View {
        VStack() {
            HStack(){
                Text("URL")
                    .multilineTextAlignment(.leading)
                    .frame(width: 85, alignment: .trailing)
                HStack {
                TextField("https://sample.jamfcloud.com", text: $loginViewModel.enteredURL)
                    .textContentType(.URL)
                    .disableAutocorrection(true)
                }
                .padding(.horizontal, 7.0)
                .frame(idealWidth: 150.0 ,maxWidth: 350)
                .background(Color.init("TextBackground"))
                .cornerRadius(10)
            }
            HStack() {
                Text("Network ID")
                    .frame(width: 85, alignment: .trailing)
                HStack {
                    TextField("", text: $loginViewModel.networkID)
                    .disableAutocorrection(true)
                }
                .padding(.horizontal, 7.0)
                .frame(idealWidth: 150.0 ,maxWidth: 350)
                .background(Color.init("TextBackground"))
                .cornerRadius(10)
            }
            HStack() {
                Text("API Key")
                    .multilineTextAlignment(.leading)
                    .frame(width: 85, alignment: .trailing)
                HStack {
                SecureField("", text:  $loginViewModel.apiKey)
                }
                .padding(.horizontal, 7.0)
                .frame(idealWidth: 150.0 ,maxWidth: 350)
                .background(Color.init("TextBackground"))
                .cornerRadius(10)
            }
            HStack() {
                Toggle(isOn: $loginViewModel.saveCredentials) {
                EmptyView()
                }
                .frame(width: 100.0, alignment: .trailing)
                Text("Save Credentials")
                    .frame(width: 350.0, height: 22.0, alignment: .leading)
            }
            .frame(width: 350.0, height: 22.0)
            Spacer().frame(height:30)
            HStack(alignment:.top) {
//                LogoView().scaleEffect(1)
//                    .frame(width: 200.0, height: 200.0)
                Button(action: {
                    self.loginViewModel.login() {
                        (credentials, devices) in
                        self.completion(credentials, devices)
                        DispatchQueue.main.async {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                }) {
                    Text("Login")
                        .padding(.all, 10.0)
                }
                .fixedSize()
                .background(Color.init("TextBackground"))
                .cornerRadius(10)

            }
            HStack {
                Text(loginViewModel.serverError)
                    .padding(.all, 10.0)
                    .multilineTextAlignment(.center)
            }

        }
        .disabled(self.loginViewModel.loggingIn)
        .onAppear {
            self.loginViewModel.loadCredentials()
            if self.loginViewModel.readConfig() {
                self.loginViewModel.login() {
                    (credentials, devices) in
                    self.completion(credentials, devices)
                    DispatchQueue.main.async {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView() {
            (credentials,devices)  in
            
        }
    }
}
