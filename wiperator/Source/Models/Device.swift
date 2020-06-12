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
    var isCheckedIn: Bool {
        get {
            return notes == "Checked In"
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


extension Device{

    
    
    static func DeviceRequest(request: URLRequest, session: URLSession, completion: @escaping (Result<DeviceResponse,Error>)-> Void)-> URLSessionDataTask? {
        let dataTask = session.dataTask(request: request) {
            (result) in
            switch result {
            case .success(let data):
                print(String(data: data, encoding: .utf8)!)
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let responseObject = try decoder.decode(DeviceResponse.self, from: data)
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
        return dataTask
    }
    
    static func DeviceRequest(baseURL: URLComponents,udid: String,credentials: String, session: URLSession, completion: @escaping (Result<DeviceResponse,Error>)-> Void)-> URLSessionDataTask? {
        var urlComponents = baseURL
        urlComponents.path="/api/devices/\(udid)"
        guard let myUrl = urlComponents.url else {
            completion(.failure(NSError()))
            return nil
        }
        let myRequest = URLRequest(url: myUrl,basicCredentials:credentials, method: HTTPMethod.get,accept: ContentType.json)
        let dataTask = DeviceRequest(request: myRequest, session: session){
            (result) in
            completion(result)
        }
        return dataTask
    }
    
    static func AllDevicesRequest(request: URLRequest, session: URLSession, completion: @escaping (Result<AllDevices,Error>)-> Void)-> URLSessionDataTask? {
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
        return dataTask
    }
    
    static func AllDevicesRequest(baseURL: URLComponents,filters: [URLQueryItem] = [],credentials: String, session: URLSession, completion: @escaping (Result<AllDevices,Error>)-> Void)-> URLSessionDataTask? {
        var urlComponents = baseURL
        urlComponents.path="/api/devices"
        urlComponents.queryItems = filters
        guard let myUrl = urlComponents.url else {
            completion(.failure(NSError()))
            return nil
        }
        let myRequest = URLRequest(url: myUrl,basicCredentials:credentials, method: HTTPMethod.get,accept: ContentType.json)
        let dataTask = AllDevicesRequest(request: myRequest, session: session){
            (result) in
            completion(result)
        }
        return dataTask
    }
}


