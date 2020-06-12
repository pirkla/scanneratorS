//
//  URLSessionExtension.swift
//  LicenseUnborker
//
//  Created by Andrew Pirkl on 3/13/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation
import os.log

extension URLSession {
    /**
     Run a dataTask escaping a result optionally adding a token provider for just in time authentication
     */
    func dataTask(request: URLRequest, result: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTask {
        return dataTask(with: request) { (data, response, error) in
            if let error = error {
                result(.failure(error))
                return
            }
            guard let response = response, let data = data else {
                result(.failure(DataTaskError.emptyData))
                return
            }
            guard let urlResponse = response as? HTTPURLResponse else {
                result(.failure(DataTaskError.unknown))
                return
            }
            let statusCode = urlResponse.statusCode
            if statusCode < 200 || statusCode > 299 {
                result(.failure(DataTaskError.requestFailure(description: HTTPURLResponse.localizedString(forStatusCode: statusCode), statusCode: statusCode)))
                return
            }
            result(.success(data))
        }
    }
    
    func fetchDecodedResponse<T: Decodable>(request: URLRequest, completion: @escaping (Result<T,Error>)-> Void) -> URLSessionDataTask
    {
        let dataTask = self.dataTask(request: request) {
            (result) in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let responseObject = try decoder.decode(T.self, from: data)
                    completion(.success(responseObject))
                }
                catch {
                    os_log("Error returned: %@", type: .error,error.localizedDescription)
                    completion(.failure(error))
                }
            case .failure(let error):
                os_log("Error returned: %@", type: .error,error.localizedDescription)
                completion(.failure(error))
            }
        }
        dataTask.resume()
        return dataTask
    }
}
