//
//  ConversationListViewController.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-03-20.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import UIKit

protocol ConversationListScreenDelegate: AnyObject {
    func conversationClicked(conversation: RomaConversation, avatar: UIImage?)
}

class ConversationListScreen: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var conversationsData : [RomaConversation]?
    
    weak var delegate: ConversationListScreenDelegate?
    
    override init() {
        conversationsData = nil
        super.init()
    }
    
    func initData(_ conversations: [RomaConversation]) {
        self.conversationsData = conversations
    }
    
    //MARK: - UITableViewDelegate & UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let conversations = conversationsData {
            return conversations.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationListCell") as! ConversationListCell

        if let conversations = conversationsData, conversations.count > indexPath.row {
            let conversation = conversations[indexPath.row]
            if let lastAccount = conversation.accounts.last {
                cell.lblTitle?.text = lastAccount.username
                
                lastAccount.getCachedAvatarImage { (avatarImage) in
                    //refresh cell image if cell is visible
                    DispatchQueue.main.async {
                        cell.imgAvatarView.image = avatarImage
                        cell.reloadInputViews()
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let conversations = conversationsData, conversations.count > indexPath.row {
            let conversation = conversations[indexPath.row]
            if let lastAccount = conversation.accounts.last {
                lastAccount.getCachedAvatarImage { (avatarImage) in
                    DispatchQueue.main.async {
                        self.delegate?.conversationClicked(conversation: conversation, avatar: avatarImage)
                    }
                }
            }
        }
    }
    
}
