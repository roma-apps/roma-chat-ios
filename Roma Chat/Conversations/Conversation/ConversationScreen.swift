//
//  ConversationScreen.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-04-04.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import UIKit

class ConversationScreen: UIView, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var conversationTableView: UITableView!
    
    var avatar : UIImage?
    
    // Our custom view from the XIB file
    var view: UIView!
    
    var conversation: RomaConversation?
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        
        let nib = UINib.init(nibName: String(describing: ConversationScreen.self), bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        instances = InstanceData.getAllInstances()
//        accounts = Account.getAccounts()
//        //TODO: use current instance to determine corresponding account
//        let account = accounts[0]
//        lblAccountName.text = account.username
        conversationTableView.dataSource = self
        conversationTableView.delegate = self
        conversationTableView.register(UINib(nibName: "ConversationCell", bundle: nil), forCellReuseIdentifier: "ConversationCell")
    }
    
    func refreshData() {
        guard let conversation = conversation else { return }
        
        for message in conversation.messages {
            if let status = message {
                print("Meessage: \(String(describing: status.content))")
            }
        }
        
        conversationTableView.reloadData()
    }
    
    
    //MARK: - UITableViewDelegate & UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let conversation = conversation {
            return conversation.messages.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell") as! ConversationCell
        
//        if let conversations = conversationsData, conversations.count > indexPath.row {
//            let conversation = conversations[indexPath.row]
//            if let lastAccount = conversation.accounts.last {
//                cell.lblTitle?.text = lastAccount.username
//            }
//        }
        
        return cell
    }
    
}
