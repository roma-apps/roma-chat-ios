//
//  RomaConversation.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-04-05.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import Foundation
import UIKit

public class RomaConversation {
    /// The conversation ID.
    public let id: String
    /// The involved accounts.
    public let accounts: [Account]
    /// The last status in the thread.
    public let lastStatus: Status?
    /// Whether the message has been read.
    public let unread: Bool
    /// Message list
    
    /// The avatar image to be displayed on the navigation bar and conversation list cell
    public var avatarThumbnailImage: UIImage?
    
    public var messages: [Status?]
    
    init(_ conversation: Conversation, messages: [Status?]) {
        self.id = conversation.id
        self.accounts = conversation.accounts
        self.lastStatus = conversation.lastStatus
        self.unread = conversation.unread
        
        //init local properties
        self.messages = messages
        
        //Lazy fetch the avatar image
        guard let account = self.accounts.last else { return }
        ApiManager.shared.fetchAvatarForAccount(account: account) { [weak self] image in
            self?.avatarThumbnailImage = image
        }
    }
    

}

extension RomaConversation: Equatable {}

public func ==(lhs: RomaConversation, rhs: RomaConversation) -> Bool {
    let areEqual = lhs.id == rhs.id &&
        lhs.id == rhs.id
    
    return areEqual
}
