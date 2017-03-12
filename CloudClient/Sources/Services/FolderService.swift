//
//  FolderService.swift
//  Cloud.mail.ru
//
//  Created by Владимир Елизаров on 08.03.17.
//
//

import Foundation

fileprivate let homeFolder: String = "/"


struct FolderService {
    
    static func getRootFolder() -> Either<HomeFolder> {
        
        let params = [ "token": AuthService.token!,
                       "home" : homeFolder ]
        
        return getFolder(with: params)
    }
    
    
    static func getFolder(home: Folder) -> Either<HomeFolder> {
        
        let params = ["token": AuthService.token!,
                      "home" : home.home ]

        return getFolder(with: params)
    }
    
    
    private static func getFolder(with params: JSON) -> Either<HomeFolder> {
        
        guard
              let value = CloudService.get(method: "/folder", params:params).value
            , let body = value["body"] as? JSON
            , let folder = HomeFolder(json: body)
            else { return .fail(CCError.getFolderError) }
        
        return .success(folder)
    }
}
