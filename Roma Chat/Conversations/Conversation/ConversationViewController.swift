//
//  ConversationViewController.swift
//  Roma Chat
//
//  Created by Monica Brinkman on 2019-05-22.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var fakeKeyboardHeightCnst: NSLayoutConstraint!

    @IBOutlet weak var msgTextField: UITextField!

    @IBOutlet weak var lblChatUsername: UILabel!
    var avatar : UIImage?
    
    var conversation: RomaConversation?
    
    var accounts: [Account]?
    @IBOutlet weak var navigationBarView: UIView!
    
    var chatUsername: String?
    
    let greenColor = UIColor(red:0.15, green:0.71, blue:0.15, alpha:1.0)
    
    @IBOutlet weak var imgBack: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    private let tableReuseIdentifier = "ConversationTableViewCell"
    
    //MARK: App Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(conversationsRefreshed(_:)), name: .init("conversations_refreshed"), object: nil)
        
        
        msgTextField.tintColor = NotificationName.shared.mfcGreen
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: tableReuseIdentifier, bundle: nil), forCellReuseIdentifier: tableReuseIdentifier)
        tableView.keyboardDismissMode = .interactive
        tableView.separatorStyle = .none
        
        imgBack.image = UIImage(named: "back")!.withRenderingMode(.alwaysTemplate)
        imgBack.tintColor = .white
        
        setupAccounts()

    }
    
    func setupAccounts() {
        guard let conversation = conversation, let chatUser = conversation.user else { return }
        self.chatUsername = chatUser.username
        
        lblChatUsername.text = chatUsername?.uppercased()
        lblChatUsername.layoutIfNeeded()
        
        let currentUsername = StoreStruct.currentUser.username
        let convAccounts = conversation.accounts
        self.accounts = convAccounts.filter{ $0.username != currentUsername }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                let keyboardHeight = keyboardSize.height
                self.fakeKeyboardHeightCnst.constant = keyboardHeight
                self.view.layoutIfNeeded()
                print("keyboard height: \(keyboardHeight)")
                guard let conversation = self.conversation, conversation.messages.count > 0 else {return}
            
                self.tableView.scrollToRow(at: IndexPath(item: conversation.messages.count - 1, section: 0), at: .bottom, animated: true)

        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                self.fakeKeyboardHeightCnst.constant = 0
                self.view.layoutIfNeeded()
                print("keyboard height hide: \(keyboardSize.height)")
        }
    }
    
    @objc func conversationsRefreshed(_ notification: Notification) {
        
        print("conversations refreshed")
        guard let conversation = conversation else { return }
        let thisConvo = StoreStruct.conversations.filter{ $0.id == conversation.id }.first
        self.conversation = thisConvo
        
        DispatchQueue.main.async {

            self.tableView.reloadData()
            self.tableView.scrollToRow(at: IndexPath(item: conversation.messages.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshData()
    }
    
    func refreshData() {
        guard let conversation = conversation else { return }
        
        for message in conversation.messages {
            if let status = message {
                print("Meessage: \(String(describing: status.content))")
            }
        }
        
        tableView.reloadData()
//        let lastMessageIndex = conversation.messages.count - 1
//        conversationCollectionView.scrollToItem(at: IndexPath(row: lastMessageIndex, section: 0), at: UICollectionView.ScrollPosition.bottom, animated: true)
    }
    
    //MARK: - Button Actions
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false, completion: nil)
//        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSendClicked(_ sender: UIButton) {
        //send message and display
        
        var replyToId: String?
        
        if let conversation = conversation, let lastStatus = conversation.lastStatus {
            replyToId = lastStatus.id
        }
        
        guard let msg = msgTextField.text, msg.isEmpty == false  else { return }
        
        let filteredMsg = tagIfNotTaggedChatUser(msg: msg)
        
        ApiManager.shared.sendDirectMessageStatus(message: filteredMsg, replyToId: replyToId)
        
        msgTextField.text = ""
        
        //refresh conversation list from backend
    }
    
    //MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let conversation = conversation {
            return conversation.messages.count
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: tableReuseIdentifier) as? ConversationTableViewCell {
            
            if let conversation = conversation {
                if let status = conversation.messages[indexPath.row] {
                    let username = status.account.username
                    let message = status.content.stripHTML()
                    
                    if shouldShowDate(index: indexPath.row) {
                        //Show date and name
                        cell.setDate(date: status.createdAt, show: true)
                        cell.setName(name: username, show: true)
                    } else if shouldShowName(index: indexPath.row) {
                        //show name no date
                        cell.setDate(date: nil, show: false)
                        cell.setName(name: username, show: true)
                    } else {
                        //hide both
                        cell.setDate(date: nil, show: false)
                        cell.setName(name: "", show: false)
                    }
                    
                    if username == StoreStruct.currentUser.username {
                        cell.setupForCurrentUser(currentUser: true)
                    } else {
                        cell.setupForCurrentUser(currentUser: false)
                    }
                    
                    if status.mediaAttachments.count > 0 {
                        print("has attachments")
                        if let firstAttachment = status.mediaAttachments.first {
                            cell.showImage(attachment: firstAttachment)
                        } else {
                            cell.toggleAttachmentsView(hide: true)
                        }
                    } else {
                        cell.toggleAttachmentsView(hide: true)
                    }
                    
//                    cell.lblName?.text = username
                    let trimmedMessage = trimLeadingUserReferences(message: message)

                    cell.lblMessage?.text = trimmedMessage
                }
            }
            
            return cell
            
        }
        return UITableViewCell()
    }
    
    //MARK: - Helpers

    //if should show date, then you should show name too
    func shouldShowDate(index: Int) -> Bool {
        if index == 0 { return true }
        
        if let curItem = conversation?.messages[index], let prevItem = conversation?.messages[index - 1] {
            let interval = curItem.createdAt.timeIntervalSince(prevItem.createdAt)
            
            let days = floor(interval / 86400)
            
            if days > 0 {
                return true
            }
            
        }
        
        return false
        
    }
    
    func shouldShowName(index: Int) -> Bool {
        if index == 0 { return true }
        
        if let curItem = conversation?.messages[index], let prevItem = conversation?.messages[index - 1] {
            
            if curItem.account.username != prevItem.account.username {
                return true
            }
        }
        
        return false
    }
    
    func trimLeadingUserReferences(message: String) -> String {
        
        var newString = message
        
        if let chatUsername = chatUsername {
            let prefixReferenceChatUser = "@\(chatUsername)"

            if newString.hasPrefix(prefixReferenceChatUser) {
                let parsedString = newString.replacingOccurrences(of: prefixReferenceChatUser, with: "")
                newString = parsedString
            }
        }
        
        let prefixRefenceMe = "@\(StoreStruct.currentUser.username)"
        
        if newString.hasPrefix(prefixRefenceMe) {
            let parsedString = newString.replacingOccurrences(of: prefixRefenceMe, with: "")
            newString = parsedString
        }
        
        let trimmedString = newString.trimmingCharacters(in: .whitespaces)
        
        return trimmedString
    }
    
    //Used to tag all accounts in this chat if no account is tagged in the message
    func tagIfNotTaggedAllAccounts(msg: String) -> String {
        
        let tagChar = "@"
        
        if msg.contains(tagChar) {
            return msg
        } else {
            //tag all users not current user
            
            guard let accounts = self.accounts else { return msg }
            
            var fullMsg = ""
            for account in accounts {
                fullMsg += "@\(account.username) "
            }
            
            fullMsg += msg
            
            return fullMsg
        }
        
    }
    
    //used to tag only the specified chat user if no other is tagged
    func tagIfNotTaggedChatUser(msg: String) -> String {
        
        let tagChar = "@"
        
        if msg.contains(tagChar) {
            return msg
        } else {
            //tag chat user
            guard let chatUsername = self.chatUsername else { return msg }
            return "@\(chatUsername) \(msg)"
        }
    }
    
    
}
