//
//  FileService.swift
//  CloudClient
//
//  Created by Владимир Елизаров on 12.03.17.
//  Copyright © 2017 Владимир Елизаров. All rights reserved.
//

import Foundation


struct FileService {
    
    private static func getURL(for file:File) -> URL? {
        
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return directory?.appendingPathComponent(file.name)
        
    }
    
    static func get(file: File) -> Either<URL> {
        guard
            let fileURL = getURL(for: file)
            else { return .fail(CCError.fileManagerError) }
        
        CloudService.load(from: file.home, to: fileURL, params: [:])
        return .success(fileURL)
    }
    
}
