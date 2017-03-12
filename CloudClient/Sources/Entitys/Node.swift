//
//  Node.swift
//  Cloud.mail.ru
//
//  Created by Владимир Елизаров on 08.03.17.
//
//

import Foundation

public class Node {
    
    public var name: String
    public var size: Int
    public var home: String
    
    public var type: String {
        return "node"
    }
    
    static func from(json: JSON) -> Node? {
        
        guard
            let nodeType = json["type"] as? String
        else { return nil }
        
        switch nodeType {
        case "folder" where ((json["list"] as? [JSON])?.count ?? 0) > 0:
                        return HomeFolder(json: json)
        case "folder":  return Folder(json: json)
        case "file":    return File(json: json)
        default:        return Node(json: json)
        }
    }
    
    init?(json: JSON) {
        
        guard
            let _name = json["name"] as? String,
            let _size = json["size"] as? Int,
            let _home = json["home"] as? String
        else { return nil }
        
        self.name = _name
        self.size = _size
        self.home = _home
    }
}


public class Folder: Node {
    
    public let countSubfolders: (folders:Int, files:Int)
    
    override public var type: String {
        return "folder"
    }
    
    override init?(json: JSON) {
        
        guard
            let counts = json["count"] as? JSON,
            let folders = counts["folders"] as? Int,
            let files = counts["files"] as? Int
        else { return nil }
        
        self.countSubfolders = (folders, files)
        
        super.init(json: json)
    }
}

public class HomeFolder: Folder {
    
    public private(set) var list:[Node] = []
    
    override public  var type: String {
        return "root_folder"
    }
    
    override init?(json: JSON) {
        
        if let _list = json["list"] as? [JSON] {
            self.list = _list.flatMap(Node.from)
        }
        
        super.init(json: json)
    }
}

public class File: Node {
    
    public private(set) var hash: String
    
    override public var type: String {
        return "file"
    }
    
    override init?(json: JSON) {
        
        guard
            let _hash = json["hash"] as? String
            else { return nil }
        
        self.hash = _hash
        super.init(json: json)
    }
}
