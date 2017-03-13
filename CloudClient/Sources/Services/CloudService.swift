//
//  CloudService.swift
//  Cloud.mail.ru
//
//  Created by Владимир Елизаров on 08.03.17.
//
//

import Foundation
import Alamofire


typealias JSON = [String:Any]


fileprivate let queue = DispatchQueue(
    label: "com.djd.cmr.response-queue",
    qos: .utility,
    attributes: [.concurrent])



struct CloudService {
    
    static func getAuth(method: String, params: JSON = [:]) -> Either<JSON> {
        return get(url: authURL + method, params: params)
    }
    
    
    static func get(method: String, params: JSON = [:]) -> Either<JSON> {
        return get(url: apiURL + method, params: params)
    }
    
    
    private static func get(url: String, params: JSON) -> Either<JSON> {
        
        let semaphore = DispatchSemaphore.init(value: 0)
        var result: Either<JSON>? = nil
        
        Alamofire
            .request(url, method: .get, parameters: params)
            .responseJSON(queue: queue) { r in
                
                if let json = r.value as? JSON {
                    result = .success(json)
                }
                else {
                    result = .fail(CCError.failParce)
                }
                
                semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return result!
    }
    
    
    static func post(method: String, params: JSON) -> Bool {
        
        let semaphore = DispatchSemaphore.init(value: 0)
        var result: Bool = false
        
        Alamofire
            .request(apiURL + method, method: .get, parameters: params)
            .response(queue: queue) { r in
                
                if let status = r.response?.statusCode,
                    200..<300 ~= status {
                    result = true
                }
                
                semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return result
    }
    
    
    static func load(from: String, to:URL, params: JSON) {
        
        let semaphore = DispatchSemaphore.init(value: 0)
        
        let destination: DownloadRequest.DownloadFileDestination = { tempURL, _ in
            (to, DownloadRequest.DownloadOptions.removePreviousFile)
        }
        
        Alamofire
            .download(getFileURL + from, to: destination)
            .response(queue: queue) { response in
                print(response)
                
                semaphore.signal()
            }
        
        _ = semaphore.wait(timeout: .distantFuture)
    }
    
}
