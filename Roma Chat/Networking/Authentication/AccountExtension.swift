//
//  AccountExtension.swift
//  mastodon
//
//  Created by Barrett Breshears on 12/7/18.
//  Copyright © 2018 Shihab Mehboob. All rights reserved.
//

import UIKit


extension Account: Equatable {
    
    // fetch cached avatar image
    
    func getCachedAvatarImage(completion:@escaping (_ avatarImage:UIImage?) -> Void ) {
        
        let imageCache = NSCache<AnyObject, AnyObject>()
        
        if let imageFromCache = imageCache.object(forKey: avatar as AnyObject) as? UIImage {
            completion(imageFromCache)
            return
        }
        
        ApiManager.shared.fetchAvatarForAccount(account: self) { (image) in
            DispatchQueue.main.async {
                imageCache.setObject(image, forKey: self.avatar as AnyObject)
                completion(image)
            }
        }
        
    }
        
    
    
    static func addAccountToList(account:Account) {
        
        guard let accountsData = UserDefaults.standard.object(forKey: "allAccounts") as? Data, var accounts = try? PropertyListDecoder().decode(Array<Account>.self, from: accountsData) else {
            let accounts = [account]
            UserDefaults.standard.set(try? PropertyListEncoder().encode(accounts), forKey:"allAccounts")
            return
        }
        
        accounts.append(account)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(accounts), forKey:"allAccounts")
        
    }
    
    static func getAccounts() -> [Account] {
        
        guard let accountsData = UserDefaults.standard.object(forKey: "allAccounts") as? Data, let accounts = try? PropertyListDecoder().decode(Array<Account>.self, from: accountsData) else {
            return [Account]()
        }
        return accounts
        
    }
    
    static func clearAccounts() {
        UserDefaults.standard.setValue(nil, forKey: "allAccounts")
    }
    
    static public func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.username == rhs.username && lhs.id == rhs.id
    }
    
    static func accountWithID(accountID:String) -> Account? {
        let accounts = getAccounts()
        let currentAccount = accounts.filter { $0.id == accountID }
        if currentAccount.isEmpty { return nil }
        
        return currentAccount.first
    }
    
}
