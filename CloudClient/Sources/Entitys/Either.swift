//
//  Either.swift
//  tbot
//
//  Created by Владимир Елизаров on 05.12.16.
//
//

import Foundation


public enum Either<T> {
    case success(T)
    case fail(Error)
}

extension Either {
    
    var value:T? {
        switch self {
        case .success(let v): return v
        default: return nil
        }
    }
    
}
