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
private let kUserAgentStub = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_1) AppleWebKit/604.3.5 (KHTML, like Gecko) Version/11.0.1 Safari/604.3.5"

fileprivate let queue = DispatchQueue(
    label: "com.djd.cmr.response-queue",
    qos: .utility,
    attributes: [.concurrent])

fileprivate let MAX_UPLOADING_FILES = 2


struct CloudService {
    
    private static let uploadSemaphore = DispatchSemaphore.init(value: MAX_UPLOADING_FILES)
    
    
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
    
    static func download(from: String, to:URL, params: JSON, progress: @escaping (Progress) -> Void) {
        
        let semaphore = DispatchSemaphore.init(value: 0)
        
        let destination: DownloadRequest.DownloadFileDestination = { tempURL, _ in
            (to, DownloadRequest.DownloadOptions.removePreviousFile)
        }
        
        Alamofire
            .download(getFileURL + from, to: destination)
            .downloadProgress(closure: progress)
            .response(queue: queue) { response in
                print(response)
                semaphore.signal()
            }
        
        _ = semaphore.wait(timeout: .distantFuture)
    }
    
    

    
    
    /// Загружает указанный файл в облако. Загрузка будет проходить в 2 этапа -
    /// 1 первым будет отправлен сам файл в общее облачное хранилище и в случае успеха будет возвращен хэш этого файла
    /// 2 при наличии хэша будет выполнен запрос на добавление файла в указанную дирректорию по этому хэшу
    static func upload(_ upload:Upload, to destination:String, completionHandler:@escaping (Bool) -> Void) {
        
        
        let headers: [String: String] = [
            "token": AuthService.token!,
            "X-Requested-With": "XMLHttpRequest",
            "Content-Type" : "image/jpeg",
            "Connection": "keep-alive",
            "Content-Length" : String(upload.size),
            "User-Agent": kUserAgentStub,
            "Origin" : "https://cloud.mail.ru",
            "Referer": "https://cloud.mail.ru/home",
            "home" : homeFolder(for: upload)
        ]
        
        uploadSemaphore.wait()
        
        let requestURL = "\(destination)?cloud_domain=2&x-email=flie@inbox.ru"
        
        Alamofire
            .request(requestURL, method: .put, parameters: nil, encoding: upload.data, headers: headers)
            .responseString { (response) in
                if case .success(let hash) = response.result {
                    print(hash)
                    addUploadedFile(upload, hash: hash, completionHandler: completionHandler)
                } else {
                    print(response)
                    completionHandler(false)
                }

                uploadSemaphore.signal()
            }

    }
    
    
    /// При наличии хэша, который отождествляется с загруженным файлом в общий
    /// каталог , будет выполнено добавления файла, чей хэш передан в
    /// дирректорию которая указана в Upload параметре
    private static func addUploadedFile(_ upload:Upload, hash:String, completionHandler:@escaping (Bool) -> Void) {
        
        let body:[String : Any] = [
            "api": "2",
            "conflict": "rename",//"rewrite" is one more discovered option
            "home": homeFolder(for: upload),
            "hash": hash,
            "size": upload.size,
            "token": AuthService.token!
        ]
        
        let url = apiURL + "/file/add"
        Alamofire
            .request(url, method: .post, parameters: body)
            .responseString {
                switch $0.result {
                case .success(let response):
                    print(response)
                    completionHandler(true)
                case .failure(let error):
                    print("Upload produce the error:\n")
                    print(error)
                    completionHandler(false)
                }
        }
    }
    
}

private func homeFolder(for upload: Upload) -> String {
    return upload.home + (upload.home.hasSuffix("/") ? upload.name : "/\(upload.name)")
}


extension Data: ParameterEncoding {
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = self//data(using: .utf8, allowLossyConversion: false)
        return request
    }
    
}
