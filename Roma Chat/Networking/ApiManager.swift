//
//  ApiManager.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-03-26.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

/* HOW TO USE APIMANAGER
     //fetch timelines
     Spinner.shared.showSpinner(show: .show)
     ApiManager.shared.fetchTimelines {
         //proceed
         Spinner.shared.showSpinner(show: .hide)
        // do something with the result here
     }
 */

import Foundation
import UIKit

struct ApiManager {
    
    init(){ }
    
    static var shared = ApiManager()
    
    //TODO: Error reporting
    
    /// Fetches the list of timelines from the Plemora API for the currently signed in user account.
    func fetchTimelines(completion: @escaping () -> ()) {
        let request = Timelines.home()
        StoreStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                StoreStruct.statusesHome = stat
                StoreStruct.statusesHome = NSOrderedSet(array: StoreStruct.statusesHome).array as! [Status]
                NotificationCenter.default.post(name: NotificationName.shared.timelines, object: nil)
                completion()
            }
        }
    }
    
    /// Fetches the list of conversations from the Plemora API for the currently signed in user account.
    func fetchConversations(completion: @escaping () -> ()) {
        let request = Conversations.conversations()
        StoreStruct.client.run(request) { (directMessages) in
            if let convos = (directMessages.value) {
                StoreStruct.directMessages = convos
                StoreStruct.directMessages = NSOrderedSet(array: StoreStruct.directMessages).array as! [Conversation]
                NotificationCenter.default.post(name: NotificationName.shared.conversations, object: nil)
                
                //Concatenate messages from same user into one RomaConversation
                
                let groupedDirectMessages = Dictionary(grouping: StoreStruct.directMessages, by: { $0.accounts.first?.id })
                var filteredConversations = [String: [Conversation]]()
                for key in groupedDirectMessages {
                    var tempConversations = key.value
                    
                    tempConversations.sort {
                        guard let status0 = $0.lastStatus, let status1 = $1.lastStatus else { return false }
                        return status0.createdAt < status1.createdAt
                    }

                    if let id = key.key {
                        filteredConversations[id] = tempConversations
                    } else {
                        if let firstConvo = tempConversations.first {
                            filteredConversations[firstConvo.id] = tempConversations
                        }
                    }
                }
                
                //convert filetered conversations into RomaConversation
                var romaConversations = [RomaConversation]()
                for key in filteredConversations {
                    guard let firstConversation = key.value.first else { continue }
                    let conversationMessages = key.value.map { $0.lastStatus }
                    let romaConversation = RomaConversation(firstConversation, messages: conversationMessages)
                    romaConversations.append(romaConversation)
                }
                
                StoreStruct.conversations = romaConversations


                completion()
            }
        }
    }
    
    func fetchAvatarForAccount(account: Account, completion: @escaping (UIImage) -> ()) {
    
        // get the deal image
        guard let imageUrl = URL(string: account.avatar) else { return }
        
        let request = URLRequest(url: imageUrl)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            
            guard let data = data else {
                return
            }

            guard let image = UIImage(data: data) else { return }
            
            // self.imageCache[unwrappedImage] = image
            completion(image)
                
        })
        task.resume()
        
    }
    
    /*
     /// Swift 5 API Calls and error handling using new Result class
     
     func fetchUnreadCount1(from urlString: String, completionHandler: @escaping (Result<Int, Error>) -> Void)  {
     guard let url = URL(string: urlString) else {
     completionHandler(.failure(.badURL))
     return
     }
     
     // complicated networking code here
     print("Fetching \(url.absoluteString)...")
     completionHandler(.success(5))
     }
     
     fetchUnreadCount1(from: "https://www.hackingwithswift.com") { result in
     switch result {
     case .success(let count):
     print("\(count) unread messages.")
     case .failure(let error):
     print(error.localizedDescription)
     }
     }
 
 
 
     */
    
}
