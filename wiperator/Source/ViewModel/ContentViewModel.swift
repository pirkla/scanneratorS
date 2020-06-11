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

    var credentials: Credentials = Credentials(Username: "", Password: "", Server: URLComponents())
    @Published var errorText: String?
    var searchTask: URLSessionDataTask?
    @Published var assetTag: String = "" {
        willSet(newValue){
            searchTask?.cancel()
            searchTask = DeviceSearch(searchType: self.searchModelArray[self.searchIndex].value, search: newValue){
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
//                        print(error)
                    }
                }
            }
        }
    }
    @Published var deviceArray = Array<Device>()
        
    var searchModelArray = [ SearchModel(title:"Serial Number", value: "serialnumber"),
                             SearchModel(title:"Asset Tag", value: "assettag")
    ]
    @Published var searchIndex = 0
    
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
//                        print(devices)
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    self?.deviceArray = Array<Device>()
                    print(error)
                }
            }
        }
    }
        
//    func checkCameraAccess(completion: @escaping (Bool)->Void) {
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//            case .authorized:
//                completion(true)
//            default:
//                AVCaptureDevice.requestAccess(for: .video) { granted in
//                    if granted {
//                        completion(true)
//                    }
//                    else {
//                        completion(false)
//                    }
//                }
//        }
//    }
}
