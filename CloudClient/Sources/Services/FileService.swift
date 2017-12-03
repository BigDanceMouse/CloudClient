//
//  FileService.swift
//  CloudClient
//
//  Created by Владимир Елизаров on 12.03.17.
//  Copyright © 2017 Владимир Елизаров. All rights reserved.
//

import Foundation

private let kUserAgentStub = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_1) AppleWebKit/604.3.5 (KHTML, like Gecko) Version/11.0.1 Safari/604.3.5"


struct FileService {

    
    static func get(file: File, progress: @escaping (Progress) -> Void) -> Either<URL> {
        guard
            let fileURL = getURL(for: file)
            else { return .fail(CCError.fileManagerError) }
        let preparedURL = file.home.replacingOccurrences(of: " ", with: "%20")
        CloudService.download(from: preparedURL, to: fileURL, params: [:], progress: progress )
        return .success(fileURL)
    }
    
    
    private static func getURL(for file:File) -> URL? {
        let directory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        return directory?.appendingPathComponent(file.name)
    }
    
    
    static func upload(_ upload: Upload, completionHandler:@escaping (Bool) -> Void) {
        
        let url = uploadFileURL
        
        let home = upload.home + upload.name
        
        let params: [String: String] = [
            "token": AuthService.token!,
            "X-Requested-With": "XMLHttpRequest",
            "Content-Type" : "image/jpeg",
            "Connection": "keep-alive",
            "Content-Length" : String(upload.size),
            "User-Agent": kUserAgentStub,
            "Origin" : "https://cloud.mail.ru",
            "Referer": "https://cloud.mail.ru" + upload.home,
            "home" : home
        ]
        
        CloudService.upload(upload, to: url, headers: params, completionHandler:completionHandler)
    }
    
}
