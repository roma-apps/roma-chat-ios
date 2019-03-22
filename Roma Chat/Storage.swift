//
//  Storage.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-03-21.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import Foundation

struct Storage {
    
    init(){ }
    
    static var shared = Storage()
    
    var authenticationUrl: String? {
        get {
            if let val = UserDefaults.standard.string(forKey: "authenticationUrl") {
                return val
            } else { return nil }
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: "authenticationUrl")
        }
    }
    
    var authenticationClient: Client?
    
    var authenticationLocalInstances: [String]?
    
    var authCode: String? {
        get {
            if let val = UserDefaults.standard.string(forKey: "authCode") {
                return val
            } else { return nil }
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: "authCode")
        }
    }
    
    var tappedSignInCheck: Bool {
        get {
            return  UserDefaults.standard.bool(forKey: "tappedSignInCheck")
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: "tappedSignInCheck")
        }
    }
    
    var clientID: String? {
        get {
            if let val = UserDefaults.standard.string(forKey: "clientID") {
                return val
            } else { return nil }
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: "clientID")
        }
    }
    
    var clientSecret: String? {
        get {
            if let val = UserDefaults.standard.string(forKey: "clientSecret"){
                return val
            } else { return nil }
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: "clientSecret")
        }
    }
    
    var returnedText: String? {
        get {
            if let val = UserDefaults.standard.string(forKey: "returnedText") {
                return val
            } else { return nil }
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: "returnedText")
        }
    }
    
    var redirect: String? {
        get {
            if let val = UserDefaults.standard.string(forKey: "redirect") {
                return val
            } else { return nil }
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: "redirect")
        }
    }
    
    
    
}
