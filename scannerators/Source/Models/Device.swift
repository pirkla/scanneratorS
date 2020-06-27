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
    var owner: Owner?
    
    var username: String? {
        return owner?.username
    }
    var fullname: String? {
        guard let owner = owner else {
            return nil
        }
        return "\(owner.firstName ?? "") \(owner.lastName ?? "")"
    }
    
    var isCheckedIn: Bool? {
        get {
            guard let notes = notes else {
                return nil
            }
            if notes.range(of: "Checked In", options: .caseInsensitive) != nil {
                return true
            }
            else if notes.range(of: "Checked Out", options: .caseInsensitive) != nil {
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
        case owner
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

struct Owner: Codable {
    var id: Int?
    var locationId: Int?
    var inTrash: Bool?
    var deviceCount: Int?
    var username: String?
    var email: String?
    var firstName: String?
    var lastName: String?
    var notes: String?
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
}


