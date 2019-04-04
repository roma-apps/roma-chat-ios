//
//  Timelines.swift
//  MastodonKit
//
//  Created by Drasko Vucenovic on 31/4/19.
//  Copyright © 2017 MastodonKit. All rights reserved.
//

import Foundation

/// `Conversations` requests.
public enum Conversations {
    /// Retrieves the conversations.
    ///
    /// - Parameter range: The bounds used when requesting data from Mastodon.
    /// - Returns: Request for `[Conversation]`.
    public static func conversations(range: RequestRange = .default) -> Request<[Conversation]> {
        let parameters = range.parameters(limit: between(1, and: 40, default: 20))
        let method = HTTPMethod.get(.parameters(parameters))
        
        return Request<[Conversation]>(path: "/api/v1/conversations", method: method)
    }
    
//    /// Retrieves the public timeline.
//    ///
//    /// - Parameters:
//    ///   - local: Only return statuses originating from this instance.
//    ///   - range: The bounds used when requesting data from Mastodon.
//    /// - Returns: Request for `[Status]`.
//    public static func `public`(local: Bool? = nil, range: RequestRange = .default) -> Request<[Status]> {
//        let rangeParameters = range.parameters(limit: between(1, and: 40, default: 20)) ?? []
//        let localParameter = [Parameter(name: "local", value: local.flatMap(trueOrNil))]
//        let method = HTTPMethod.get(.parameters(localParameter + rangeParameters))
//
//        return Request<[Status]>(path: "/api/v1/timelines/public", method: method)
//    }
//
//    /// Retrieves a tag timeline.
//    ///
//    /// - Parameters:
//    ///   - hashtag: The hashtag.
//    ///   - local: Only return statuses originating from this instance.
//    ///   - range: The bounds used when requesting data from Mastodon.
//    /// - Returns: Request for `[Status]`.
//    public static func tag(_ hashtag: String, local: Bool? = nil, range: RequestRange = .default) -> Request<[Status]> {
//        let rangeParameters = range.parameters(limit: between(1, and: 40, default: 20)) ?? []
//        let localParameter = [Parameter(name: "local", value: local.flatMap(trueOrNil))]
//        let method = HTTPMethod.get(.parameters(localParameter + rangeParameters))
//
//        return Request<[Status]>(path: "/api/v1/timelines/tag/\(hashtag)", method: method)
//    }
}
