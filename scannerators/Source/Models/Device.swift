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
struct DeviceResponse: Codable {
    var code: Int?
    var device: Device
}
struct Device: Codable, Identifiable {
    var id : UUID? = UUID()
    var UDID: String?
    var locationId: Int?
    var serialNumber: String?
    var assetTag: String?
    var inTrash: Bool?
    var name: String?
    var apps: [App]?
    var os : OSType?
    var notes: String?
    var isCheckedIn: Bool? {
        get {
            if notes == "Checked In" {
                return true
            }
            else if notes == "Checked Out" {
                return false
            }
            return nil
        }
    }
    var isiOS: Bool {
        get {
            return os?.prefix == "iOS"
        }
    }
    
    enum CodingKeys: CodingKey {
        case UDID
        case locationId
        case serialNumber
        case assetTag
        case inTrash
        case name
        case apps
        case os
        case notes
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

extension Device: Hashable {
    static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.UDID == rhs.UDID && lhs.serialNumber == rhs.serialNumber
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(UDID)
        hasher.combine(serialNumber)
    }
}
    
extension App: Hashable {
    static func == (lhs: App, rhs: App) -> Bool {
        return lhs.name == rhs.name && lhs.identifier == rhs.identifier && lhs.version == rhs.version
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(identifier)
        hasher.combine(version)
    }
}

extension OSType: Hashable {
    static func == (lhs: OSType, rhs: OSType) -> Bool {
        return lhs.prefix == rhs.prefix && lhs.version == rhs.version
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(prefix)
        hasher.combine(version)
    }
}
    
    
extension Device{
    
    static func deviceRequest(baseURL: URLComponents,udid: String,credentials: String, session: URLSession, completion: @escaping (Result<DeviceResponse,Error>)-> Void)-> URLSessionDataTask? {
        var urlComponents = baseURL
        urlComponents.path="/api/devices/\(udid)"
        guard let myUrl = urlComponents.url else {
            completion(.failure(NSError()))
            return nil
        }
        let myRequest = URLRequest(url: myUrl,basicCredentials:credentials, method: HTTPMethod.get,accept: ContentType.json)
        return session.fetchDecodedResponse(request: myRequest) {
            (result: Result<DeviceResponse, Error>) in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func allDevicesRequest(baseURL: URLComponents,filters: [URLQueryItem] = [],credentials: String, session: URLSession, completion: @escaping (Result<AllDevices,Error>)-> Void)-> URLSessionDataTask? {
        var urlComponents = baseURL
        urlComponents.path="/api/devices"
        urlComponents.queryItems = filters
        guard let myUrl = urlComponents.url else {
            completion(.failure(NSError()))
            return nil
        }
        let myRequest = URLRequest(url: myUrl,basicCredentials:credentials, method: HTTPMethod.get,accept: ContentType.json)
        return session.fetchDecodedResponse(request: myRequest) {
            (result: Result<AllDevices, Error>) in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    static func broadSearchRequest(baseURL: URLComponents, searchValue: String, credentials: String, session: URLSession, completion: @escaping (Result<[Device],Error>)-> Void)-> [URLSessionDataTask?] {
        var urlSessionDataTaskArray = [URLSessionDataTask?]()
        var devicesArray = [Device]()
//        let deviceSet = Set<Device>()
        
        var urlComponents = baseURL
        urlComponents.path="/api/devices"
        
        let nameQuery = [URLQueryItem(name: "name",value: searchValue)]
        let snQuery = [URLQueryItem(name: "serialnumber",value: searchValue)]
        let assetQuery = [URLQueryItem(name: "assettag",value: searchValue)]
            
        let group = DispatchGroup()
        
        group.enter()
        urlSessionDataTaskArray.append(allDevicesRequest(baseURL: baseURL, filters: nameQuery, credentials: credentials, session: session) {
            (result: Result<AllDevices, Error>) in
            switch result {
            case .success(let data):
                devicesArray.append(contentsOf: data.devices)
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
            group.leave()
        })
        
        group.enter()
        urlSessionDataTaskArray.append(allDevicesRequest(baseURL: baseURL, filters: snQuery, credentials: credentials, session: session) {
            (result: Result<AllDevices, Error>) in
            switch result {
            case .success(let data):
                devicesArray.append(contentsOf: data.devices)
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
            group.leave()
        })
        
        group.enter()
        urlSessionDataTaskArray.append(allDevicesRequest(baseURL: baseURL, filters: assetQuery, credentials: credentials, session: session) {
            (result: Result<AllDevices, Error>) in
            switch result {
            case .success(let data):
                devicesArray.append(contentsOf: data.devices)
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
            group.leave()
        })
        
        DispatchQueue.global().async {
            group.wait()
            let deviceSet = Set(devicesArray)
            completion(.success(Array(deviceSet)))
        }
        
        return urlSessionDataTaskArray
    }
}


