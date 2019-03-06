//
//  NetworkFacilities.swift
//  TemplateApp
//
//  Created by John Kuang on 2018-11-05.
//  Copyright © 2018 JandJ. All rights reserved.
//

import Foundation

public class NetworkFacilities: NSObject, DataTaskProtocol {
    
    // this layer handles and terminates http headers, JWT, automatic retry on network failure, etc.
    
    public enum HTTPMethod: String {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
    }
    
    public var extra_resonse_delay_milliseconds: Int = 0 // add an extra delay onto response time for purposes of testing and/or debugging
    
    public var dataTaskState: DataTaskState = .undefined
    
    public func dataTask(method: HTTPMethod, sURL: String, headers dictHeaders: Dictionary<String, String>?, body dictBody: Dictionary<String, Any>?, completion: @escaping (Bool, Dictionary<String, Any>) -> ()) {
        var dictResponse: [String:Any] = ["__REQUEST__": ["URL": sURL, "METHOD": method.rawValue], "__CARRIER__": self]
        if let url = URL(string: sURL) {
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            var dictHeaders: [String:String] = dictHeaders ?? [:]
            let contentType = dictHeaders["content-type"]
            if contentType == nil {
                dictHeaders["content-type"] = "application/json"
            }
            for (httpHeaderField, value) in dictHeaders {
                request.addValue(value, forHTTPHeaderField: httpHeaderField)
            }
            if (dictBody != nil) && (dictBody!.count > 0) {
                request.httpBody = try! JSONSerialization.data(withJSONObject: dictBody!, options: [])
            }
            
            self.dataTaskState = .active
            _ = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
                DispatchQueue.main.asyncAfter(deadline: (.now() + .milliseconds(self.extra_resonse_delay_milliseconds)), execute: {
                    if self.dataTaskState == .active {
                        if let _ = urlResponse,
                            let data = data,
                            let jsonData = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
                            dictResponse["__RESPONSE__"] = jsonData
                            completion(true, dictResponse)
                        } else {
                            dictResponse["__ABNORMAL__"] = "Abnormal in response."
                            completion(false, dictResponse)
                        }
                    }
                    else {
                        print("Response discarded due to data task state(\(self.dataTaskState.rawValue)).")
                        // suspended or cancelled, does not expect responding
                        // let dictResponse = ["__DISCARDED__":"Response discarded due to data task state(\(self.dataTaskState.rawValue))."]
                        // completion(dictResponse, urlResponse, error)
                    }
                })}.resume()
        }
        else {
            dictResponse["__RESPONSE__"] = "Invalid URL"
            completion(false, dictResponse)
        }
    }
    
}
