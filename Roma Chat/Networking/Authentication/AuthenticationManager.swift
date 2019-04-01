//
//  AuthenticationManager.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-03-21.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

struct AuthenticationManager {
    
    init(){ }
    
    static var shared = AuthenticationManager()
    
    func authenticate(_ text: String, proceed: @escaping (SFSafariViewController) -> ()) {
            StoreStruct.client = Client(baseURL: "https://\(text)")
            let request = Clients.register(
                clientName: "Romachat",
                redirectURI: "com.romachat://success",
                scopes: [.read, .write, .follow, .push],
                website: "https://github.com/wonderlabs"
            )
            StoreStruct.client.run(request) { (application) in
                
                if application.value == nil {} else {
                    
                    let application = application.value!
                    
                    StoreStruct.shared.currentInstance.clientID = application.clientID
                    StoreStruct.shared.currentInstance.clientSecret = application.clientSecret
                    StoreStruct.shared.currentInstance.returnedText = text
                    
                    DispatchQueue.main.async {
                        StoreStruct.shared.currentInstance.redirect = "com.romachat://success".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                        let queryURL = URL(string: "https://\(text)/oauth/authorize?response_type=code&redirect_uri=\(StoreStruct.shared.currentInstance.redirect)&scope=read%20write%20follow%20push&client_id=\(application.clientID)")!
                        UIApplication.shared.open(queryURL, options: [.universalLinksOnly: true]) { (success) in
                            if !success {
                                proceed(SFSafariViewController(url: queryURL))
                            }
                        }
                    }
            }
        }
    }
    
    func fetchAccessToken(proceed: @escaping (Bool) -> ()) {
        
        //    self.loginBG.removeFromSuperview()
        //    self.loginLogo.removeFromSuperview()
        //    self.loginLabel.removeFromSuperview()
        //    self.textField.removeFromSuperview()
        //    self.termsButton.removeFromSuperview()
        //    self.safariVC?.dismiss(animated: true, completion: nil)
        
        var request = URLRequest(url: URL(string: "https://\(StoreStruct.shared.currentInstance.returnedText)/oauth/token?grant_type=authorization_code&code=\(StoreStruct.shared.currentInstance.authCode)&redirect_uri=\(StoreStruct.shared.currentInstance.redirect)&client_id=\(StoreStruct.shared.currentInstance.clientID)&client_secret=\(StoreStruct.shared.currentInstance.clientSecret)&scope=read%20write%20follow%20push")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                proceed(false)
                print(error!)
                return
            }
            
            guard let data = data else {
                proceed(false)
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                    
                    StoreStruct.shared.currentInstance.accessToken = (json["access_token"] as! String)
                    StoreStruct.client.accessToken = StoreStruct.shared.currentInstance.accessToken
                    
                    
                    let currentInstance = InstanceData(clientID: StoreStruct.shared.currentInstance.clientID, clientSecret: StoreStruct.shared.currentInstance.clientSecret, authCode: StoreStruct.shared.currentInstance.authCode, accessToken: StoreStruct.shared.currentInstance.accessToken, returnedText: StoreStruct.shared.currentInstance.returnedText, redirect:StoreStruct.shared.currentInstance.redirect)
                    
                    var instances = InstanceData.getAllInstances()
                    
                    if !instances.contains(currentInstance){
                        instances.append(currentInstance)
                    }
                    let request2 = Accounts.currentUser()
                    StoreStruct.client.run(request2) { (statuses) in
                        if let account = (statuses.value) {
                            
                            UserDefaults.standard.set(try? PropertyListEncoder().encode(instances), forKey:"instances")
                            InstanceData.setCurrentInstance(instance: currentInstance) //TODO: Load conversations and feed instead of timelines
                            let request = Timelines.home()
                            StoreStruct.client.run(request) { (statuses) in
                                if let stat = (statuses.value) {
                                    DispatchQueue.main.async {
                                        StoreStruct.currentUser = account
                                        Account.addAccountToList(account: account)
                                        StoreStruct.statusesHome = NSOrderedSet(array: stat).array as! [Status] //remove duplicates
                                        proceed(true)
//                                        NotificationCenter.default.post(name: Notification.Name(rawValue: "refresh"), object: nil)
//                                        NotificationCenter.default.post(name: Notification.Name(rawValue: "refProf"), object: nil)
                                    }
                                }
                            }
                            
                        }
                    }
                    
                    // onboarding
                    if (UserDefaults.standard.object(forKey: "onb") == nil) || (UserDefaults.standard.object(forKey: "onb") as! Int == 0) {
                        DispatchQueue.main.async {
//                            self.bulletinManager.prepare()
//                            self.bulletinManager.presentBulletin(above: self, animated: true, completion: nil)
                        }
                    }
                    
                    
                    
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    //TODO: do this smarter, ensure access token and all data is wiped permanently.
    func logout() {
        var instance = InstanceData.getAllInstances()
        var account = Account.getAccounts()
        account.remove(at: 0)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(account), forKey:"allAccounts")
        instance.remove(at: 0)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(instance), forKey:"instances")

        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.logout()
    }
    
}
