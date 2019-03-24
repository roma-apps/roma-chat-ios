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
            Storage.shared.authenticationClient = Client(baseURL: "https://\(text)")
            let request = Clients.register(
                clientName: "Romachat",
                redirectURI: "com.romachat://success",
                scopes: [.read, .write, .follow, .push],
                website: "https://github.com/wonderlabs"
            )
            Storage.shared.authenticationClient?.run(request) { (application) in
                
                if application.value == nil {} else {
                    
                    let application = application.value!
                    
                    Storage.shared.clientID = application.clientID
                    Storage.shared.clientSecret = application.clientSecret
                    Storage.shared.returnedText = text
                    
                    DispatchQueue.main.async {
                        let redirect = "com.shi.mastodon://success".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                        let queryURL = URL(string: "https://\(text)/oauth/authorize?response_type=code&redirect_uri=\(redirect)&scope=read%20write%20follow%20push&client_id=\(application.clientID)")!
                        UIApplication.shared.open(queryURL, options: [.universalLinksOnly: true]) { (success) in
                            if !success {
                                proceed(SFSafariViewController(url: queryURL))
                            }
                        }
                    }
            }
        }
    }
}
