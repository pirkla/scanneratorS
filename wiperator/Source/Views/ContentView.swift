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
    
    var body: some View {
        VStack() {
            HStack() {
                Button(action: {
                    self.contentViewModel.activeSheet = .login
                }) {
                    Text("Login")
                }
            }
            Spacer()
            HStack() {
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
                        self.contentViewModel.activeSheet = .scanner
                    }) {
                        Image(systemName: "camera.fill")
                    }
                    #endif

                    TextField("", text:  $contentViewModel.assetTag)
                }
                .frame(width: 350.0, height: 22.0)
                .background(Color.init("TextBackground"))
            }
            #if targetEnvironment(macCatalyst)
            NavigationView {
            DeviceListView(deviceArray: self.contentViewModel.deviceArray, credentials: self.contentViewModel.credentials, updateFunc: self.contentViewModel.UpdateNotes)
            }
            #else
            NavigationView {
            DeviceListView(deviceArray: self.contentViewModel.deviceArray, credentials: self.contentViewModel.credentials, updateFunc: self.contentViewModel.UpdateNotes)
            }.navigationViewStyle(StackNavigationViewStyle())
            #endif
        }
        .sheet(isPresented: self.$contentViewModel.showSheet) {
            self.contentViewModel.currentModal()
        }
        .frame(minWidth: 200, idealWidth: 400, maxWidth: .infinity)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
