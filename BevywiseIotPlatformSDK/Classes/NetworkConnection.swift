//
//  NetworkConnection.swift
//  Bevywise Platform Connector
//
//  Created by Prince J on 29/05/18.
//  Copyright © 2018 Bevywise Networks Inc. All rights reserved.
//

import Foundation

enum ConnectionErrorCode: Int {
    case NO_ERROR, TIMED_OUT, WRONG_STATUS, UNKNOWN_ERROR, JSON_ERROR, AUTHENTICATION_FAILED, CANCELLED
}

class NetworkConnection {
    static let shared = NetworkConnection()
    
    func networkOperation(_ datatask: inout URLSessionDataTask?, _ urlRequest: inout URLRequest, _ postString: String,onSuccess: @escaping (_:[String: Any?]) -> (), onFailure: @escaping (_:String,_:ConnectionErrorCode) ->()) {
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = postString.data(using: String.Encoding.utf8)
        dataNetworkOperation(&datatask, &urlRequest, onSuccess, onFailure)
    }
    
    func networkOperation(_ datatask: inout URLSessionDataTask?,_ urlRequest: inout URLRequest,_ postString: String, _ token: String, onSuccess: @escaping (_:[String: Any?]) -> (), onFailure: @escaping (_:String,_:ConnectionErrorCode) ->()) {
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = postString.data(using: String.Encoding.utf8)
        dataNetworkOperation(&datatask, &urlRequest, onSuccess, onFailure)
    }
    
    func networkOperation(_ datatask: inout URLSessionDataTask?, _ urlRequest: inout URLRequest,token: String, onSuccess: @escaping (_:[String: Any?]) -> (), onFailure: @escaping (_:String,_:ConnectionErrorCode) ->()) {
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        dataNetworkOperation(&datatask, &urlRequest, onSuccess, onFailure)
    }
    
    func dataNetworkOperation(_ datatask: inout URLSessionDataTask?,_ urlRequest: inout URLRequest,_ onSuccess: @escaping (_:[String: Any?]) -> (),_ onFailure: @escaping (_:String,_:ConnectionErrorCode) ->()) {
        var failureReason = ""
        urlRequest.timeoutInterval = 10
        var failureCode = ConnectionErrorCode.NO_ERROR
        let defaultSession: URLSession = URLSession(configuration: .default)
        datatask = defaultSession.dataTask(with: urlRequest, completionHandler: {(data, response, error) -> Void in
            if let sessionError = error {
                if sessionError is URLError {
                    let urlError = sessionError as! URLError
                    failureReason = urlError.localizedDescription
                    if urlError.errorCode == -999 {
                        failureCode = ConnectionErrorCode.CANCELLED
                    } else {
                        failureCode = ConnectionErrorCode.TIMED_OUT
                    }
                } else {
                    failureReason = sessionError.localizedDescription
                    failureCode = ConnectionErrorCode.UNKNOWN_ERROR
                }
            } else if let data = data, let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    do {
                        if let jsonDictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any?] {
                            DispatchQueue.main.async {
                                print(jsonDictionary)
                                onSuccess(jsonDictionary)
                            }
                        }
                    } catch _ as NSError {
                        failureReason = "Server sent invalid response.Check the server api."
                        failureCode = ConnectionErrorCode.JSON_ERROR
                        onFailure(failureReason,failureCode)
                    }
                } else if response.statusCode == 401 {
                    failureReason = "Invalid input or token expired"
                    do {
                        if let jsonDictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any?] {
                            DispatchQueue.main.async {
                                print(jsonDictionary)
                                onSuccess(jsonDictionary)
                            }
                        }
                    } catch _ as NSError {
                        failureReason = "Server sent invalid response.Check the server api."
                        failureCode = ConnectionErrorCode.JSON_ERROR
                        onFailure(failureReason,failureCode)
                    }
                    failureCode = ConnectionErrorCode.AUTHENTICATION_FAILED
                } else {
                    do {
                        if let jsonDictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any?] {
                            print(jsonDictionary)
                            failureReason = jsonDictionary["bwapi-status-reason"] as? String ?? ""
                        }
                    } catch _ as NSError {
                        failureReason = "Server sent invalid response.Check the server api."
                        failureCode = ConnectionErrorCode.JSON_ERROR
                        DispatchQueue.main.async {
                            onFailure(failureReason, failureCode)
                        }
                    }
                    //failureReason = "Received wrong status fix the server api"
                    failureCode = ConnectionErrorCode.WRONG_STATUS
                    DispatchQueue.main.async {
                        onFailure(failureReason, failureCode)
                    }
                }
            }
            if (failureCode != .NO_ERROR && failureCode != .CANCELLED) {
                DispatchQueue.main.async {
                    onFailure(failureReason, failureCode)
                }
            }
        })
        datatask?.resume()
    }
}
