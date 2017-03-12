//
//  Operators.swift
//  CloudClient
//
//  Created by Владимир Елизаров on 12.03.17.
//  Copyright © 2017 Владимир Елизаров. All rights reserved.
//

import Foundation


precedencegroup MonadicPrecedence {
    higherThan: NilCoalescingPrecedence
    associativity: left
    assignment: false
}

infix operator >>=
    : MonadicPrecedence

@_transparent
@discardableResult
public func >>=<T,U>(val:T?, f:(T) -> U) -> U? {
    
    if let just = val { return f(just) }
    else { return nil }
}


@_transparent
public func >>=<T,U>(val:Either<T>, f:(T) -> Either<U>) -> Either<U> {
    
    switch val{
    case .success(let x): return f(x)
    case .fail(let err): return Either<U>.fail(err)
    }
}


infix operator +?: MonadicPrecedence

public func +?<T>(val:Either<T>, f:(T) -> ()) {
    
    if case .success(let x) = val {
        f(x)
    }
}


