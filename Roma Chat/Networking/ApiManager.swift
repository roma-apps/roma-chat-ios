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

struct ApiManager {
    
    init(){ }
    
    static var shared = ApiManager()
    
    //TODO: Error reporting
    
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
    
    func fetchConversations(completion: @escaping () -> ()) {
        let request = Conversations.conversations()
        StoreStruct.client.run(request) { (conversations) in
            if let convos = (conversations.value) {
                StoreStruct.conversations = convos
                StoreStruct.conversations = NSOrderedSet(array: StoreStruct.conversations).array as! [Conversation]
                NotificationCenter.default.post(name: NotificationName.shared.conversations, object: nil)
                completion()
            }
        }
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
