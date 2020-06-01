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
    
    struct DataTaskError: LocalizedError{
        enum ErrorKind {
            case emptyData
            case requestFailure
            case unknown
        }
        let errorDescription: String?
        let kind: ErrorKind
        let statusCode: Int
    }
    
    
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
                let error = DataTaskError(errorDescription: "No response or data, something went wrong", kind: DataTaskError.ErrorKind.emptyData, statusCode: -1)
                result(.failure(error))
                return
            }
            guard let urlResponse = response as? HTTPURLResponse else {
                let error = DataTaskError(errorDescription: "an unknown error ocurred", kind: DataTaskError.ErrorKind.requestFailure,statusCode: -1)
                result(.failure(error))
                return
            }
            let statusCode = urlResponse.statusCode
            if statusCode < 200 || statusCode > 299 {
                let localizedString = "\(String(statusCode)): \(HTTPURLResponse.localizedString(forStatusCode: statusCode))"
                let error = DataTaskError(errorDescription: localizedString, kind: DataTaskError.ErrorKind.requestFailure,statusCode: statusCode)
                result(.failure(error))
                return
            }
            result(.success(data))
        }
    }
    /**
     Run an array of dataTasks, escaping an array of results optionally adding a token provider for just in time authentication
     */
//    func dataTaskArray(batchSize:Int=10,batchDelay:Double=0.05, requestArray: [URLRequest], resultArray: @escaping ([Result<Data, Error>]) -> Void) -> [URLSessionDataTask] {
//
//        var myTaskArray = [URLSessionDataTask]()
//
//        DispatchQueue.global().async{
//            let startTime = Date()
//            os_log("Starting data task array", type: .info)
//
//
//            var myResultArray = [(Result<(Data), Error>)]()
//
//            let batchedRequests = requestArray.batched(batchSize: batchSize)
//            for batch in batchedRequests
//            {
//                let group = DispatchGroup()
//                for request in batch {
//                    group.enter()
//                    let myDataTask = self.dataTask(request: request)
//                    {
//                        (result) in
//                        myResultArray.append(result)
//                        group.leave()
//                    }
//                    myTaskArray.append(myDataTask)
//                    myDataTask.resume()
//                }
//                usleep(UInt32(batchDelay * 1000000))
//                group.wait()
//                os_log("batch completed", type: .debug)
//
//            }
//            let runTime = startTime.timeIntervalSince(Date())
//            os_log("data task array completed in: %@ seconds", type: .info,String(-runTime))
//
//            resultArray(myResultArray)
//
//        }
//        return myTaskArray
//    }
    
    
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
    
//    static func FetchDecodedResponseArray<T: Decodable>(requestArray: [URLRequest], session: URLSession, completion: @escaping ([Result<T,Error>])-> Void) -> [URLSessionDataTask]
//    {
//        var resultArray=[Result<T,Error>]()
//        let taskArray = session.dataTaskArray(requestArray: requestArray){
//            (results: [Result<Data, Error>]) in
//            for result in results{
//                switch result {
//                case .success(let data):
//                    do {
//                        let decoder = JSONDecoder()
//                        decoder.keyDecodingStrategy = .convertFromSnakeCase
//                        let responseObject = try decoder.decode(T.self, from: data)
//                        resultArray.append(.success(responseObject))
//                    }
//                    catch {
//                        os_log("Error returned: %@", type: .error,error.localizedDescription)
//                        resultArray.append(.failure(error))
//                    }
//                case .failure(let error):
//                    os_log("Error returned: %@", type: .error,error.localizedDescription)
////                    completion(.failure(error))
//                    resultArray.append(.failure(error))
//                }
//            }
//            completion(resultArray)
//        }
//        return taskArray
//    }
}
