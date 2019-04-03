//
//  ConversationListViewController.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-03-20.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import UIKit

class ConversationListScreen: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var conversationsData : [Conversation]?
    
    func initData(_ conversations: [Conversation]) {
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
            }
        }
        
        return cell
    }
    
}
