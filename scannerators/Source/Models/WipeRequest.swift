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
    
    func submitWipeRequest(baseURL: URLComponents,credentials: String,session: URLSession, completion: @escaping (Result<JSResponse,Error>)->Void){
        var urlComponents = baseURL
        urlComponents.path="/api/devices/\(self.udid ?? "")/wipe"
        guard let myUrl = urlComponents.url else {
            return completion(.failure(NSError()))
        }
        
        let jsonData = self.toJSON()
        
        let myRequest = URLRequest(url: myUrl,basicCredentials:credentials, method: HTTPMethod.post, dataToSubmit: jsonData, contentType: ContentType.json, accept: ContentType.json)
        
        let dataTask = session.dataTask(request: myRequest) {
            (result) in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let responseObject = try decoder.decode(JSResponse.self, from: data)
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
