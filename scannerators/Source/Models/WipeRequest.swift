//
//  WipeRequest.swift
//  wiperator
//
//  Created by Andrew Pirkl on 6/7/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation

struct WipeRequest: Codable {
    var udid: String?
    var clearActivationLock: String
    enum CodingKeys: CodingKey {
        case clearActivationLock
    }
}


extension WipeRequest{
    func toJSON() -> Data? {
        let encoder = JSONEncoder()
        guard let dataToSubmit = try? encoder.encode(self) else {
            return nil
        }
        return dataToSubmit
    }
    
    func submitWipeRequest(baseURL: URLComponents,credentials: String,session: URLSession, completion: @escaping (Result<JSResponse,Error>)-> Void )-> URLSessionDataTask? {
        var urlComponents = baseURL
        urlComponents.path="/api/devices/\(self.udid ?? "")/wipe"
        guard let myUrl = urlComponents.url else {
            completion(.failure(NSError()))
            return nil
        }
        
        let jsonData = self.toJSON()
        
        let myRequest = URLRequest(url: myUrl,basicCredentials:credentials, method: HTTPMethod.post, dataToSubmit: jsonData, contentType: ContentType.json, accept: ContentType.json)
        
        return session.fetchDecodedResponse(request: myRequest) {
            (result: Result<JSResponse, Error>) in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
