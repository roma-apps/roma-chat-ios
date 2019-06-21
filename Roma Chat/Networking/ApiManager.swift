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
    func fetchHomeTimelines(completion: @escaping () -> ()) {
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
    
    /// Fetches the list of public timelines from the Plemora API for the currently signed in user account.
    func fetchPublicTimelines(completion: @escaping () -> ()) {
        let request = Timelines.public()
        StoreStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                StoreStruct.statusesFederated = stat
                StoreStruct.statusesFederated = NSOrderedSet(array: StoreStruct.statusesFederated).array as! [Status]
                NotificationCenter.default.post(name: NotificationName.shared.timelines, object: nil)
                completion()
            }
        }
    }
    
    /// Fetches the list of timelines from the Plemora API for the currently signed in user account.
    func fetchDirectTimelines(completion: @escaping () -> ()) {
        let request = Timelines.direct()
        StoreStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                StoreStruct.statusesDirect = stat
                StoreStruct.statusesDirect = NSOrderedSet(array: StoreStruct.statusesDirect).array as! [Status]
                NotificationCenter.default.post(name: NotificationName.shared.timelines, object: nil)

                //Concatenate messages from same user into one RomaConversation

                let groupedDirectMessages = Dictionary(grouping: StoreStruct.statusesDirect, by: { $0.account.id })
                var filteredConversations = [String: [Status]]()
                for key in groupedDirectMessages {
                    var tempConversations = key.value

                    tempConversations.sort {
                        return $0.createdAt < $1.createdAt
                    }

                    filteredConversations[key.key] = tempConversations
                }

                //convert filetered conversations into RomaConversation
                var romaConversations = [RomaConversation]()
                for key in filteredConversations {
                    guard let firstConversation = key.value.first else { continue }
                    let conversationMessages = key.value.map { $0 }
                    let romaConversation = RomaConversation(firstConversation, messages: conversationMessages, user: firstConversation.account) //this is the wrong account logic
                    romaConversations.append(romaConversation)
                }

                StoreStruct.conversations = romaConversations

                completion()
            }
        }
    }
    
    /// Fetches the list of conversations from the Plemora API for the currently signed in user account.
    func fetchConversations(completion: @escaping (Error?) -> ()) {
        let request = Conversations.conversations()
        StoreStruct.client.run(request) { (directMessages) in
            if let convos = (directMessages.value) {
                StoreStruct.directMessages = convos
                StoreStruct.directMessages = NSOrderedSet(array: StoreStruct.directMessages).array as! [Conversation]
                NotificationCenter.default.post(name: NotificationName.shared.conversations, object: nil)
                
                let currentUsername = StoreStruct.currentUser.username
                
                var groupedDirectMessages = Dictionary<String,[Conversation]>()
                
                //Concatenate messages from same user into one RomaConversation
                
                for conversation in StoreStruct.directMessages {
//                    print("Message: \(String(describing: conversation.lastStatus?.content))")
                    for account in conversation.accounts {
                        if conversation.accounts.count > 1 { //more than just the signed in user are visible
                            if account.username != currentUsername {
                                if var statusArray = groupedDirectMessages[account.username] { //if dms contains an array of statuses for this username
                                    statusArray.append(conversation)
                                    groupedDirectMessages[account.username] = statusArray
                                } else { //add first element
                                    let statusArray = Array(arrayLiteral: conversation)
                                    groupedDirectMessages[account.username] = statusArray
                                }
                            } else {
                                print("current user but > 1 account")
                            }
                        } else {
                            if account.username == currentUsername {
                                if var statusArray = groupedDirectMessages[currentUsername] { //just the signed in user is in the conversation
                                    statusArray.append(conversation)
                                    groupedDirectMessages[account.username] = statusArray
                                } else {
                                    let statusArray = Array(arrayLiteral: conversation)
                                    groupedDirectMessages[currentUsername] = statusArray
                                }
                            } else {
                                if var statusArray = groupedDirectMessages[account.username] { //if dms contains an array of statuses for this username
                                    statusArray.append(conversation)
                                    groupedDirectMessages[account.username] = statusArray
                                } else { //add first element
                                    let statusArray = Array(arrayLiteral: conversation)
                                    groupedDirectMessages[account.username] = statusArray
                                }
                            }
                        }
                    }
                }
                
//                let groupedDirectMessages = Dictionary(grouping: StoreStruct.directMessages, by: { $0.accounts.first?.id })
                var filteredConversations = Dictionary<String,[Conversation]>()
//                filteredConversations = groupedDirectMessages
                for dict in groupedDirectMessages {
                    var tempStatuses = dict.value

                    tempStatuses.sort {
                        guard let status0 = $0.lastStatus, let status1 = $1.lastStatus else { return false }
                        return status0.createdAt < status1.createdAt
                    }
                    
                    filteredConversations[dict.key] = tempStatuses

//                    if let id = key.key {
//                        filteredConversations[id] = tempConversations
//                    } else {
//                        if let firstConvo = tempConversations.first {
//                            filteredConversations[firstConvo.id] = tempConversations
//                        }
//                    }
                }
                
                //convert filetered conversations into RomaConversation
                var romaConversations = [RomaConversation]()
                for dict in filteredConversations {
                    

                    guard let firstConversation = dict.value.first else { continue }
                    let conversationMessages = dict.value.map { $0.lastStatus }
                    guard let firstAccount = firstConversation.accounts.first else { continue }
                    var user: Account = firstAccount //just to init
                    outer: for conversation in dict.value {
                        for account in conversation.accounts {
                            if account.username == dict.key {
                                user = account
                                break outer
                            }
                        }
                    }
                    let romaConversation = RomaConversation(firstConversation, messages: conversationMessages, user: user)
                    romaConversations.append(romaConversation)
                }
                
                StoreStruct.conversations = romaConversations


                completion(nil)
            } else {
                if let error = directMessages.error {
                    completion(error)
                }
            }
        }
    }
    
    func sendDirectMessageStatus(message: String, replyToId: String?) {
        let request = Statuses.create(status: message,
                                      replyToID: nil,
                                      mediaIDs: [],
                                      sensitive: nil,
                                      spoilerText: nil,
                                      scheduledAt: nil,
                                      visibility: .direct)

        StoreStruct.client.run(request) { (status) in
            if let convos = (status.value) {
                Stream.shared.refreshConversations()

               
                print("")
//                StoreStruct.directMessages = convos
//                StoreStruct.directMessages = NSOrderedSet(array: StoreStruct.directMessages).array as! [Conversation]
//                NotificationCenter.default.post(name: NotificationName.shared.conversations, object: nil)
//
//                //Concatenate messages from same user into one RomaConversation
//
//                let groupedDirectMessages = Dictionary(grouping: StoreStruct.directMessages, by: { $0.accounts.first?.id })
//                var filteredConversations = [String: [Conversation]]()
//                for key in groupedDirectMessages {
//                    var tempConversations = key.value
//
//                    tempConversations.sort {
//                        guard let status0 = $0.lastStatus, let status1 = $1.lastStatus else { return false }
//                        return status0.createdAt < status1.createdAt
//                    }
//
//                    if let id = key.key {
//                        filteredConversations[id] = tempConversations
//                    } else {
//                        if let firstConvo = tempConversations.first {
//                            filteredConversations[firstConvo.id] = tempConversations
//                        }
//                    }
//                }
//
//                //convert filetered conversations into RomaConversation
//                var romaConversations = [RomaConversation]()
//                for key in filteredConversations {
//                    guard let firstConversation = key.value.first else { continue }
//                    let conversationMessages = key.value.map { $0.lastStatus }
//                    let romaConversation = RomaConversation(firstConversation, messages: conversationMessages)
//                    romaConversations.append(romaConversation)
//                }
//
//                StoreStruct.conversations = romaConversations
//
//
//                completion(nil)
            } else {
                if let error = status.error {
                    print(error)
//                    completion(error)
                }
            }
        }
    }
    
    func sendDirectMessageStatusForMediaAttachment(message: String, mediaIDs: [String]) {
        let request = Statuses.create(status: message,
                                      replyToID: nil,
                                      mediaIDs: mediaIDs,
                                      sensitive: nil,
                                      spoilerText: nil,
                                      scheduledAt: nil,
                                      visibility: .direct)
        
        StoreStruct.client.run(request) { (status) in
            if let convos = (status.value) {
                Stream.shared.refreshConversations()
                
                
                print("")
                //                StoreStruct.directMessages = convos
                //                StoreStruct.directMessages = NSOrderedSet(array: StoreStruct.directMessages).array as! [Conversation]
                //                NotificationCenter.default.post(name: NotificationName.shared.conversations, object: nil)
                //
                //                //Concatenate messages from same user into one RomaConversation
                //
                //                let groupedDirectMessages = Dictionary(grouping: StoreStruct.directMessages, by: { $0.accounts.first?.id })
                //                var filteredConversations = [String: [Conversation]]()
                //                for key in groupedDirectMessages {
                //                    var tempConversations = key.value
                //
                //                    tempConversations.sort {
                //                        guard let status0 = $0.lastStatus, let status1 = $1.lastStatus else { return false }
                //                        return status0.createdAt < status1.createdAt
                //                    }
                //
                //                    if let id = key.key {
                //                        filteredConversations[id] = tempConversations
                //                    } else {
                //                        if let firstConvo = tempConversations.first {
                //                            filteredConversations[firstConvo.id] = tempConversations
                //                        }
                //                    }
                //                }
                //
                //                //convert filetered conversations into RomaConversation
                //                var romaConversations = [RomaConversation]()
                //                for key in filteredConversations {
                //                    guard let firstConversation = key.value.first else { continue }
                //                    let conversationMessages = key.value.map { $0.lastStatus }
                //                    let romaConversation = RomaConversation(firstConversation, messages: conversationMessages)
                //                    romaConversations.append(romaConversation)
                //                }
                //
                //                StoreStruct.conversations = romaConversations
                //
                //
                //                completion(nil)
            } else {
                if let error = status.error {
                    print(error)
                    //                    completion(error)
                }
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
    
    func fetchThumbnailForAttachment(attachment: Attachment, completion: @escaping (UIImage) -> ()) {
        
        // get the deal image
        guard let imageUrl = URL(string: attachment.previewURL) else { return }
        
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
    
    func fetchImageForAttachment(attachment: Attachment, completion: @escaping (UIImage) -> ()) {
        
        // get the deal image
        guard let imageUrl = URL(string: attachment.url) else { return }
        
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
