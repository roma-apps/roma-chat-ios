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
    func refreshConversations(completion: @escaping () -> ())
}

class ConversationListScreen: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var conversationsData : [RomaConversation]?
    
    var backgroundView: UIView?
    
    let backgroundBlue = UIColor(red: (51/255.0), green: (174/255.0), blue: (248/255.0), alpha: 1.0)

    var fetchingConversations = true
    var refreshTriggered = false
    weak var delegate: ConversationListScreenDelegate?
    weak var conversationListScreen: UIView?
    weak var tableView: UITableView?
    
    override init() {
        super.init()
        conversationsData = nil
    }
    
    func initData(_ conversations: [RomaConversation]) {
        fetchingConversations = false
        self.conversationsData = conversations
    }
    
    func setupViews() {
        guard let conversationListScreen = conversationListScreen else { return }
        
        if backgroundView == nil {
            backgroundView = UIView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.size.width, height: 200))
            guard let backgroundView = backgroundView else { return }
            
            backgroundView.contentMode = .scaleAspectFill
            backgroundView.clipsToBounds = true
            backgroundView.backgroundColor = backgroundBlue
            conversationListScreen.addSubview(backgroundView)
            conversationListScreen.sendSubviewToBack(backgroundView)
        }

        relayoutBackground()
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
            if let user = conversation.user {
                    cell.lblTitle?.text = user.username
                    cell.backgroundColor = backgroundBlue
                    
                    user.getCachedAvatarImage { (avatarImage) in
                        //refresh cell image if cell is visible
                        DispatchQueue.main.async {
                            cell.imgAvatarView.image = avatarImage
                            cell.reloadInputViews()
                        }
                    }
            } else {
                if let lastAccount = conversation.accounts.last {
                    cell.lblTitle?.text = lastAccount.username
                    cell.backgroundColor = backgroundBlue
                    
                    lastAccount.getCachedAvatarImage { (avatarImage) in
                        //refresh cell image if cell is visible
                        DispatchQueue.main.async {
                            cell.imgAvatarView.image = avatarImage
                            cell.reloadInputViews()
                        }
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshTriggered {
            refreshTriggered = false
            if fetchingConversations { return }
            //Refresh list
            fetchingConversations = true
            self.delegate?.refreshConversations {
                print("done fetching")
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        relayoutBackground()
        if fetchingConversations { return }
        if -scrollView.contentOffset.y > UIScreen.main.bounds.height/4 {
            //Refresh list
            refreshTriggered = true
        }
    }
    
    private func relayoutBackground() {
        guard let tableView = tableView else { return }
        let tblHeight = tableView.frame.origin.y + tableView.contentSize.height
        let newHeight = UIScreen.main.bounds.size.height - tblHeight + tableView.contentOffset.y
        let newY = UIScreen.main.bounds.size.height - newHeight
        backgroundView?.frame = CGRect(x: 0, y: newY, width: UIScreen.main.bounds.size.width, height: newHeight)
    }
    
}
