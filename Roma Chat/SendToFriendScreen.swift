//
//  SendToFriendScreen.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-06-21.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import UIKit

protocol SendToFriendScreenDelegate: AnyObject {
    func friendClicked(conversation: RomaConversation)
}

class SendToFriendScreen: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var conversationsData : [RomaConversation]?
    
    var backgroundView: UIView?
    
    let backgroundBlue = UIColor(red: (51/255.0), green: (174/255.0), blue: (248/255.0), alpha: 1.0)
    
    weak var delegate: SendToFriendScreenDelegate?
    
    @IBOutlet weak var tableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "ConversationListCell", bundle: nil), forCellReuseIdentifier: "ConversationListCell")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        print("")
        self.tableView.reloadData()
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
                cell.backgroundColor = .white
                
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
                    cell.backgroundColor = .white
                    
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
            self.dismiss(animated: true) {
                self.delegate?.friendClicked(conversation: conversation)
            }
        }
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
