//
//  DeviceModel.swift
//  App Crawler
//
//  Created by Andrew Pirkl on 4/20/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation

struct AllDevices: Codable {
    var code: Int?
    var count: Int?
    var devices: [Device]
}
struct Device: Codable, Identifiable {
    var id : UUID? = UUID()
    var UDID: String?
    var locationId: Int?
    var serialNumber: String?
    var assetTag: String?
    var inTrash: Bool?
//    var class: String?
    var name: String?
    var apps: [App]?
    var model: DeviceModel?
    var os : OSType?
    
    enum CodingKeys: CodingKey {
        case UDID
        case locationId
        case serialNumber
        case assetTag
        case inTrash
        case name
        case apps
        case model
        case os
    }
}
struct DeviceModel: Codable {
    var name : String?
    var identifier : String?
    var type : String?
}
struct OSType: Codable {
    var prefix : String?
    var version : String?
}

struct App: Codable {
    var name: String?
    var vendor: String?
    var identifier: String?
    var version: String?
    var icon: String?
}

struct AppEntry {
    var name:String=""
    var version:String=""
    var deviceType:String=""
}
extension AppEntry: Hashable {
    static func == (lhs: AppEntry, rhs: AppEntry) -> Bool {
        return (lhs.name == rhs.name && lhs.version == rhs.version && lhs.deviceType == rhs.deviceType)
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(version)
        hasher.combine(deviceType)
    }
}

extension Device{
    
    func toJSON() -> Data? {
        let encoder = JSONEncoder()
        guard let dataToSubmit = try? encoder.encode(self) else {
            return nil
        }
        return dataToSubmit
    }
    
    static func AllDevicesRequest(request: URLRequest, session: URLSession, completion: @escaping (Result<AllDevices,Error>)-> Void) {
        let dataTask = session.dataTask(request: request) {
            (result) in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let responseObject = try decoder.decode(AllDevices.self, from: data)
                    completion(.success(responseObject))
                }
                catch {
                    print(error)
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        dataTask.resume()
    }
    
    static func AllDevicesRequest(baseURL: URLComponents,filters: [URLQueryItem],credentials: String, session: URLSession, completion: @escaping (Result<AllDevices,Error>)-> Void) {
        var urlComponents = baseURL
        urlComponents.path="/api/devices"
        urlComponents.queryItems = filters
        guard let myUrl = urlComponents.url else {
            return completion(.failure(NSError()))
        }
        let myRequest = URLRequest(url: myUrl,basicCredentials:credentials, method: HTTPMethod.get,accept: ContentType.json)
        AllDevicesRequest(request: myRequest, session: session){
            (result) in
            completion(result)
        }
    }
}

struct WipeRequestModel: Codable {
    var udid: String?
    var clearActivationLock: String
    enum CodingKeys: CodingKey {
        case clearActivationLock
    }
}


extension WipeRequestModel{
    
    
    
    func toJSON() -> Data? {
        let encoder = JSONEncoder()
        guard let dataToSubmit = try? encoder.encode(self) else {
            return nil
        }
        return dataToSubmit
    }
    
    static func SubmitWipeRequest(baseURL: URLComponents,credentials: String, wipeRequestModel: WipeRequestModel,session: URLSession, completion: @escaping (Result<WipeResponseModel,Error>)->Void){
        var urlComponents = baseURL
        urlComponents.path="/api/devices/\(wipeRequestModel.udid ?? "")/wipe"
        guard let myUrl = urlComponents.url else {
            return completion(.failure(NSError()))
        }
        
        let jsonData = wipeRequestModel.toJSON()
        
        let myRequest = URLRequest(url: myUrl,basicCredentials:credentials, method: HTTPMethod.post, dataToSubmit: jsonData, contentType: ContentType.json, accept: ContentType.json)
        
        let dataTask = session.dataTask(request: myRequest) {
            (result) in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let responseObject = try decoder.decode(WipeResponseModel.self, from: data)
                    print(responseObject)
                    completion(.success(responseObject))
                }
                catch {
                    print(error)
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        dataTask.resume()
    }
}

struct WipeResponseModel: Codable {
    var code: Int?
    var message: String?
    var device: String?
}
