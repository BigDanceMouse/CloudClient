//
//  FileService.swift
//  CloudClient
//
//  Created by Владимир Елизаров on 12.03.17.
//  Copyright © 2017 Владимир Елизаров. All rights reserved.
//

import Foundation


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
        
        CloudService.upload(upload, to: uploadFileURL, completionHandler:completionHandler)
    }
    
}
