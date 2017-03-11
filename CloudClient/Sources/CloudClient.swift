//
//  CloudClient.swift
//  CloudClient
//
//  Created by Владимир Елизаров on 11.03.17.
//  Copyright © 2017 Владимир Елизаров. All rights reserved.
//

import Foundation

public func authorize(login:String, password: String) {
    AuthService.auth(login: login, pass: password)
}

public func getRootFolder() -> HomeFolder? {
    
    if AuthService.notAutoriszed() {
        return nil
    }
    
    return FolderService.getRootFolder().value
}
