//
//  Upload.swift
//  CloudClient
//
//  Created by Владимир Елизаров on 19.03.17.
//  Copyright © 2017 Владимир Елизаров. All rights reserved.
//

import Foundation


public struct Upload {
    let size: Int64
    let data: Data
    let name: String
    let home: String
    
    public init(size: Int64, data: Data, folder: Folder, name: String) {
        self.size = size
        self.data = data
        self.home = folder.home
        self.name = name
    }
}
