//
//  ContentView.swift
//  wiperator
//
//  Created by Andrew Pirkl on 5/27/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var contentViewModel = ContentViewModel()
//    @ObservedObject var scannerViewModel = ScannerViewModel()
    
    @State private var showScanner = false
    @State private var showLogin = true

    
    var body: some View {
        VStack() {
            Spacer()
            HStack(alignment: .top){
                Text("URL")
                    .multilineTextAlignment(.leading)
                    .frame(width: 200.0, alignment: .trailing)
                HStack {
                TextField("https://sample.jamfcloud.com", text: $contentViewModel.enteredURL)
                    .textContentType(.URL)
                }
                .frame(width: 350.0, height: 22.0)
                .background(Color.init("TextBackground"))
            }
            HStack() {
                Text("Network ID")
                    .frame(width: 200.0, alignment: .trailing)
                HStack {
                    TextField("", text: $contentViewModel.networkID)
                }.frame(width: 350.0, height: 22.0)
                .background(Color.init("TextBackground"))
            }
            HStack() {
                Text("API Key")
                    .multilineTextAlignment(.leading)
                    .frame(width: 200.0, alignment: .trailing)
                HStack {
                SecureField("", text:  $contentViewModel.apiKey)
                }
                .frame(width: 350.0, height: 22.0)
                .background(Color.init("TextBackground"))
            }
            HStack {
                Button(action: {
                    self.contentViewModel.loadCredentials()
                }) {
                    Text("Load")
                }
                Button(action: {
                    do {
                        try self.contentViewModel.syncronizeCredentials()
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
            
            HStack() {
                Text("Search Type")
                Picker(selection: $contentViewModel.searchIndex, label: EmptyView()) {
                ForEach(0 ..< contentViewModel.searchModelArray.count) {
                    index in
                    HStack() {
                    Text(self.contentViewModel.searchModelArray[index].title)
                        .tag(index)
                    }
                    }
                }
            }
            .frame(width: 300.0, height: 80.0)
                .zIndex(-2)
            
            HStack() {
                Text("Search")
                    .multilineTextAlignment(.leading)
                    .frame(width: 200.0, alignment: .trailing)
                HStack {
                    #if !targetEnvironment(macCatalyst)
                    Button(action: {
                        self.contentViewModel.checkCameraAccess() {
                            (result) in
                            switch result{
                            case true:
                                self.showScanner = true
                            case false:
                                self.showScanner = false
                            }
                        }
                    }) {
                        Image(systemName: "camera.fill")
                    }.sheet(isPresented: self.$showScanner) {
                        CodeScannerView(codeTypes: [.qr,.aztec,.code128,.code39,.code39Mod43,.code93,.dataMatrix,.ean13,.ean8,.interleaved2of5,.itf14,.pdf417,.upce], simulatedData: "testdata") {
                            result in
                            self.showScanner = false
                            switch result {
                            case .success(let code):
                                self.contentViewModel.assetTag = code
                                print("Found code: \(code)")
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    }
                    #endif

                    TextField("", text:  $contentViewModel.assetTag)
                }
                .frame(width: 350.0, height: 22.0)
                .background(Color.init("TextBackground"))
            }
            DeviceListView(listArray: contentViewModel.deviceArray, baseUrl: self.contentViewModel.baseURL, credentials: self.contentViewModel.basicCreds)

        }.onAppear {
            self.contentViewModel.loadCredentials()
//            self.scannerViewModel.startCapture()
//            self.contentViewModel.ReadConfig()
            
        }
        .sheet(isPresented: self.$showLogin) {
            LoginView() {
                (credentials) in
                print(credentials)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(contentViewModel: ContentViewModel())
    }
}
