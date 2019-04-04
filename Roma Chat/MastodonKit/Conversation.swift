//
//  Conversation.swift
//  MastodonKit
//
//  Created by Ornithologist Coder on 4/9/17.
//  Copyright © 2017 MastodonKit. All rights reserved.
//

import Foundation

public class Conversation: Codable {
    /// The conversation ID.
    public let id: String
    /// The involved accounts.
    public let accounts: [Account]
    /// The last status in the thread.
    public let lastStatus: Status?
    /// Whether the message has been read.
    public let unread: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id
        case accounts
        case lastStatus = "last_status"
        case unread
    }
}

extension Conversation: Equatable {}

public func ==(lhs: Conversation, rhs: Conversation) -> Bool {
    let areEqual = lhs.id == rhs.id &&
        lhs.id == rhs.id
    
    return areEqual
}
