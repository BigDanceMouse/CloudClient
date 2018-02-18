//
//  CloudClient.swift
//  CloudClient
//
//  Created by Владимир Елизаров on 11.03.17.
//  Copyright © 2017 Владимир Елизаров. All rights reserved.
//

import Foundation


public typealias ProgressLoader = (Progress)->Void
public typealias LoadComplitionHandler = (Bool)->Void



public func prepare() {
    _ = AuthService.restoreToken()
}


public func logout() {
    AuthService.logout()
}

public var authorized: Bool {
    return !AuthService.notAutoriszed()
}

public func authorize(login:String, password: String) -> Bool {
    logout()
    return AuthService.auth(login: login, pass: password)
}


public func getRootFolder() -> HomeFolder? {
    
    if AuthService.notAutoriszed() {
        return nil
    }
    
    return FolderService.getRootFolder().value
}

public func getSubfolders(from folder: Folder) -> HomeFolder? {
    return FolderService.getFolder(home: folder).value
}

public func getFile(_ file:File, progress: @escaping (Progress) -> Void) -> URL? {
    return FileService.get(file: file, progress: progress).value
}

public func addFolder(to parentFolder: Folder, name: String) -> Bool {
    return FolderService.addFolder(to: parentFolder, name: name)
}

public func upload(_ upload: Upload, progressLoader: @escaping ProgressLoader, completionHandler: @escaping LoadComplitionHandler) {
    
    FileService.upload(upload,
                       progressLoader: progressLoader,
                       completionHandler: completionHandler)
}
