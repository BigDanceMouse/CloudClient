//
//  CloudClient.swift
//  CloudClient
//
//  Created by Владимир Елизаров on 11.03.17.
//  Copyright © 2017 Владимир Елизаров. All rights reserved.
//

import Foundation

public var authorized: Bool {
    return !AuthService.notAutoriszed()
}

public func authorize(login:String, password: String) -> Bool {
    return AuthService.auth(login: login, pass: password)
}

public func getRootFolder() -> HomeFolder? {
    
    if AuthService.notAutoriszed() {
        return nil
    }
    
    return FolderService.getRootFolder().value
}

public func getFile(_ file:File) -> URL? {
    return FileService.get(file: file).value
}

