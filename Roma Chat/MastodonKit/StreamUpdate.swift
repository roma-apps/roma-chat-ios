//
//  StreamUpdate.swift
//  Roma Chat
//
//  Created by Monica Brinkman on 2019-05-23.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import Foundation

public class StreamUpdate: Codable {
    /// The conversation ID.
    public let id: String
    /// The conversation ID.
    public let type: String
    /// The conversation ID.
    public let createdAt: String
    /// The involved accounts.
    public let account: Account
    /// The last status in the thread.
    public let status: Status
    
    private enum CodingKeys: String, CodingKey {
        case id
        case type
        case createdAt = "created_at"
        case account
        case status
    }
}

extension StreamUpdate: Equatable {}

public func ==(lhs: StreamUpdate, rhs: StreamUpdate) -> Bool {
    let areEqual = lhs.id == rhs.id &&
        lhs.id == rhs.id
    
    return areEqual
}
