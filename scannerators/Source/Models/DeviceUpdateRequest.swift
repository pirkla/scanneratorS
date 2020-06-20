//
//  DeviceUpdateRequest.swift
//  wiperator
//
//  Created by Andrew Pirkl on 6/7/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation

struct DeviceUpdateRequest: Codable {
    var udid: String?
    var assetTag: String?
    var notes: String?
    enum CodingKeys: CodingKey {
        case assetTag
        case notes
    }
}

extension DeviceUpdateRequest {
    func toJSON() -> Data? {
        let encoder = JSONEncoder()
        guard let dataToSubmit = try? encoder.encode(self) else {
            return nil
        }
        return dataToSubmit
    }
    func submitDeviceUpdate(baseUrl: URLComponents, credentials: String, session: URLSession, completion: @escaping (Result<JSResponse,Error>)-> Void)-> URLSessionDataTask? {
        var urlComponents = baseUrl
        
        //todo: precondition
        urlComponents.path="/api/devices/\(self.udid ?? "")/details"

        guard let myUrl = urlComponents.url else {
            completion(.failure(NSError()))
            return nil
        }
        let myRequest = URLRequest(url: myUrl,basicCredentials:credentials, method: HTTPMethod.post,dataToSubmit: self.toJSON(), accept: ContentType.json)
        
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
