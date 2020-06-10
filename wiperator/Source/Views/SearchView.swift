//
//  SearchView.swift
//  wiperator
//
//  Created by Andrew Pirkl on 5/31/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

//import SwiftUI
//
//struct SearchView: View {
//    
//    @ObservedObject var searchViewModel = SearchViewModel()
//    @State private var showScanner = false
//
//    
//    var body: some View {
//        VStack {
//            HStack() {
//                Text("Search Type")
//                Picker(selection: $searchViewModel.searchIndex, label: EmptyView()) {
//                ForEach(0 ..< searchViewModel.searchModelArray.count) {
//                    index in
//                    HStack() {
//                    Text(self.searchViewModel.searchModelArray[index].title)
//                        .tag(index)
//                    }
//                    }
//                }
//            }
//            .frame(width: 300.0, height: 80.0)
//                .zIndex(-2)
//            
//            HStack() {
//                Text("Search")
//                    .multilineTextAlignment(.leading)
//                    .frame(width: 200.0, alignment: .trailing)
//                HStack {
//                    #if !targetEnvironment(macCatalyst)
//                    Button(action: {
//                        self.searchViewModel.checkCameraAccess() {
//                            (result) in
//                            switch result{
//                            case true:
//                                self.showScanner = true
//                            case false:
//                                self.showScanner = false
//                            }
//                        }
//                    }) {
//                        Image(systemName: "camera.fill")
//                    }.sheet(isPresented: self.$showScanner) {
//                        CodeScannerView(codeTypes: [.qr,.aztec,.code128,.code39,.code39Mod43,.code93,.dataMatrix,.ean13,.ean8,.interleaved2of5,.itf14,.pdf417,.upce], simulatedData: "testdata") {
//                            result in
//                            self.showScanner = false
//                            switch result {
//                            case .success(let code):
//                                self.searchViewModel.assetTag = code
//                                print("Found code: \(code)")
//                            case .failure(let error):
//                                print(error.localizedDescription)
//                            }
//                        }
//                    }
//                    #endif
//
//                    TextField("", text:  $searchViewModel.assetTag)
//                }
//                .frame(width: 350.0, height: 22.0)
//                .background(Color.init("TextBackground"))
//
//            }
//            DeviceListView(listArray: searchViewModel.deviceArray, baseUrl: self.searchViewModel.baseURL, credentials: self.searchViewModel.basicCreds)
//        }
//    }
//}
//
//struct SearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchView()
//    }
//}
