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
    
}
