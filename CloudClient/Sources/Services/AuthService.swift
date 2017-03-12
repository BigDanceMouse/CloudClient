//
//  AuthService.swift
//  Cloud.mail.ru
//
//  Created by Владимир Елизаров on 06.03.17.
//  Copyright © 2017 Владимир Елизаров. All rights reserved.
//

import Foundation


infix operator >>=
    : MonadicPrecedence

private let tokenKey = "userTokenIdentifier"

struct AuthService {
    
    static var token: String!
    
    static func notAutoriszed() -> Bool {
        return self.token == nil
        }

    
    static func auth(login: String, pass: String) -> Bool {
        
        if !restoreToken() {
            getCookiesAndToken(login: login, pass: pass)
        }
        
        return !notAutoriszed()
        }
    
    private static func getCookiesAndToken(login: String, pass: String) {
        
        print("retrieving new token ...")
        
        let params = [
              "Login"   : login
            , "Password": pass
        ]
        
        _ = CloudService.getAuth(method: "/cgi-bin/auth", params: params)
        _ = CloudService.getAuth(method: "/sdc?from=https://cloud.mail.ru/home")
        
        CloudService.get(method: "/tokens/csrf")
            >>= AuthService.extractToken
            +? storeToken
        }
    
    private static func extractToken(response r:JSON) -> Either<String> {
        
        guard
            let body = r["body"] as? JSON,
            let token = body["token"] as? String
        else {
            return .fail(CCError.notAuthorized)
        }
        
        return .success(token)
        }
    
    private static func storeToken(_ token:String) {
        self.token = token
        UserDefaults.standard.set(token, forKey: tokenKey)
        }
    
    static func restoreToken() -> Bool {
        if let _token = UserDefaults.standard.value(forKey: tokenKey) as? String {
            print("token successfuly restored")
            self.token = _token
            return true
        }
        else {
            return false
        }}
    
    
    
    static func logout() {
        clearToken()
        clearCookies()
        }
    
    private static func clearToken() {
        self.token = nil
        UserDefaults.standard.set(nil, forKey: tokenKey)
        }
    
    private static func clearCookies() {
        removeStoredCookie(for:URL(string: authURL)!)
        removeStoredCookie(for: URL(string: apiURL)!)
        }
    
    private static func removeStoredCookie(for url: URL) {
        
        let cstorage = HTTPCookieStorage.shared
        cstorage
            .cookies(for: url)?
            .forEach { cstorage.deleteCookie($0) }
        }
    
    
}

