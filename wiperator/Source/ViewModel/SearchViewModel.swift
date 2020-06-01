//
//  SearchViewModel.swift
//  wiperator
//
//  Created by Andrew Pirkl on 5/31/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation
import AVFoundation


class SearchViewModel: ObservableObject {
    @Published var deviceArray = Array<Device>()
    var baseURL = URLComponents()
    var basicCreds: String = ""
    
    var searchModelArray = [ SearchModel(title:"Serial Number", value: "serialnumber"),
                             SearchModel(title:"Asset Tag", value: "assettag")
    ]
    @Published var searchIndex = 0
    
    @Published var assetTag: String = "" {
        willSet(newValue){
            print(newValue)
            DeviceSearch(searchType: self.searchModelArray[self.searchIndex].value, search: newValue){
                [weak self]
                (result) in
                switch result {
                case .success(let devices):
                    DispatchQueue.main.async {
                        self?.deviceArray = devices
                        print(devices)
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
    
    
    public func DeviceSearch(searchType: String, search: String, completion: @escaping (Result<[Device], Error>) -> Void){
        let queryArray = [URLQueryItem(name: searchType,value: search)]
        Device.AllDevicesRequest(baseURL: baseURL, filters: queryArray, credentials: basicCreds, session: URLSession.shared) {(result) in
            switch result {
            case .success(let allDevices):
                completion(.success(allDevices.devices))
            case .failure(let error):
                completion(.failure(error))
                print(error)
            }
        }
    }
    
    
    
    func checkCameraAccess(completion: @escaping (Bool)->Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: // The user has previously granted access to the camera.
                completion(true)
            default: // The user has not yet been asked for camera access.
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        completion(true)
                    }
                    else {
                        completion(false)
                    }
                }
        }
    }
}
