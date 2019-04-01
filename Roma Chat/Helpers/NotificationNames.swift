//
//  NotificationCenter.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-03-26.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import Foundation

struct NotificationName {
    
    init(){}
    
    static var shared = NotificationName()
    
    let timelines = NSNotification.Name(rawValue: "timelines_changed")
    let conversations = NSNotification.Name(rawValue: "conversations_changed")

}
