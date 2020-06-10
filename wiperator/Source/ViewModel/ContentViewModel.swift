//
//  ContentViewModel.swift
//  wiperator
//
//  Created by Andrew Pirkl on 5/27/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation
import AVFoundation
import Combine

class ContentViewModel: ObservableObject{

    var credentials: Credentials = Credentials(Username: "", Password: "", Server: URLComponents())

    var searchTask: URLSessionDataTask?
    @Published var assetTag: String = "" {
        willSet(newValue){
//            print(newValue)
            searchTask?.cancel()
            searchTask = DeviceSearch(searchType: self.searchModelArray[self.searchIndex].value, search: newValue){
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
    }
    let objectWillChange = PassthroughSubject<ContentViewModel,Never>()
    @Published var deviceArray = Array<Device>() {
        willSet(newValue) { objectWillChange.send(self)
        }
    }
        
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
    
    public func UpdateNotes(udid: String, notes: String) {
        _ = DeviceUpdateRequest(udid: udid, notes: notes).submitDeviceUpdate(baseUrl: credentials.Server, credentials: credentials.BasicCreds, session: URLSession.shared){
            (result) in
            switch result {
            case .success(let response):
                self.SearchBetter(searchValue: self.assetTag)
//                completion(.success(allDevices.devices))
                print(response)
            case .failure(let error):
//                completion(.failure(error))
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
    
//    public func UpdateNotes()
    
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
