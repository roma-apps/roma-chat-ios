//
//  ConversationViewController.swift
//  Roma Chat
//
//  Created by Monica Brinkman on 2019-05-22.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var conversationCollectionView: UICollectionView!
    @IBOutlet weak var fakeKeyboardHeightCnst: NSLayoutConstraint!

    @IBOutlet weak var msgTextField: UITextField!
    private let reuseIdentifier = "ConversationCell"
    
    private var reloadTriggered = false
    
    var avatar : UIImage?
    
    var conversation: RomaConversation?
    
    var accounts: [Account]?
    
    var chatUsername: String?
    
    var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.size.width
        layout.estimatedItemSize = CGSize(width: width, height: 10)
        return layout
    }()
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        //        instances = InstanceData.getAllInstances()
//        //        accounts = Account.getAccounts()
//        //        //TODO: use current instance to determine corresponding account
//        //        let account = accounts[0]
//        //        lblAccountName.text = account.username
//
//        conversationCollectionView.dataSource = self
//        conversationCollectionView.delegate = self
//        conversationCollectionView.collectionViewLayout = layout
//        conversationCollectionView.alwaysBounceVertical = true
//        conversationCollectionView.contentInsetAdjustmentBehavior = .always
//        conversationCollectionView.register(UINib(nibName: "ConversationCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        conversationCollectionView.dataSource = self
        conversationCollectionView.delegate = self
        conversationCollectionView.collectionViewLayout = layout
        conversationCollectionView.alwaysBounceVertical = true
        conversationCollectionView.contentInsetAdjustmentBehavior = .always
        conversationCollectionView.register(UINib(nibName: "ConversationCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
        conversationCollectionView.keyboardDismissMode = .interactive
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(conversationsRefreshed(_:)), name: .init("conversations_refreshed"), object: nil)
        
//        [self.collectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld context:NULL];
        
        setupAccounts()

    }
    
    func setupAccounts() {
        guard let conversation = conversation, let chatUser = conversation.user else { return }
        self.chatUsername = chatUser.username
        
        let currentUsername = StoreStruct.currentUser.username
        let convAccounts = conversation.accounts
        self.accounts = convAccounts.filter{ $0.username != currentUsername }
        print(self.accounts ?? "")
    }
    
//
//    - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary  *)change context:(void *)context
//    {
//    // You will get here when the reloadData finished
//    }

//
//
//    - (void)dealloc
//    {
//    [self.collectionView removeObserver:self forKeyPath:@"contentSize" context:NULL];
//    }
    
//    @objc func keyboardWillChangeFrame(notification: NSNotification) {
//        print("keyboard heightc changed)")
//
//        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            let keyboardHeight = keyboardFrame.size.height
//            print("keyboard height: \(keyboardHeight)")
////            conversationCollectionView.contentInset.bottom = keyboardHeight
////            conversationCollectionView.layoutIfNeeded()
//            print("keyboard height: \(keyboardHeight)")
//                        self.fakeKeyboardHeightCnst.constant = keyboardHeight
//                        self.view.layoutIfNeeded()
//            //do the chnages according ot this height
//        }
//    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.view.frame.origin.y != 0 {
                let keyboardHeight = keyboardSize.height
                self.fakeKeyboardHeightCnst.constant = keyboardHeight
                self.view.layoutIfNeeded()
                print("keyboard height: \(keyboardHeight)")
                guard let conversation = self.conversation, conversation.messages.count > 0 else {return}
                self.conversationCollectionView.scrollToItem(at: IndexPath(item: conversation.messages.count - 1, section: 0), at: .bottom, animated: true)
                
//            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.view.frame.origin.y != 0 {
                self.fakeKeyboardHeightCnst.constant = 0
                self.view.layoutIfNeeded()
                print("keyboard height hide: \(keyboardSize.height)")

//            }
        }
    }
    
    @objc func conversationsRefreshed(_ notification: Notification) {
        
        print("conversations refreshed")
        guard let conversation = conversation else { return }
        let thisConvo = StoreStruct.conversations.filter{ $0.id == conversation.id }.first

        self.conversation = thisConvo
        
        DispatchQueue.main.async {
            self.reloadTriggered = true
            self.conversationCollectionView.reloadData()
//            guard let conversation = self.conversation, conversation.messages.count > 0 else {return}
//            self.conversationCollectionView.scrollToItem(at: IndexPath(item: conversation.messages.count - 1, section: 0), at: .bottom, animated: true)
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
        
        conversationCollectionView.reloadData()
        let lastMessageIndex = conversation.messages.count - 1
        conversationCollectionView.scrollToItem(at: IndexPath(row: lastMessageIndex, section: 0), at: UICollectionView.ScrollPosition.bottom, animated: true)
    }
    
    
    //MARK: - UITableViewDelegate & UITableViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let conversation = conversation {
            return conversation.messages.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ConversationCell {
            if let conversation = conversation {
                if let status = conversation.messages[indexPath.row] {
                    let username = status.account.username
                    let message = status.content.stripHTML()
                    cell.lblUsername?.text = username
                    cell.lblMessage?.text = message
                }
            }
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    //MARK: - Collection View Layout
    //
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    //        let availableWidth = view.frame.width
    //
    //        return CGSize(width: availableWidth, height: 200)
    //    }
    //
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        layout.estimatedItemSize = CGSize(width: view.bounds.size.width, height: 10)
        super.traitCollectionDidChange(previousTraitCollection)
    }
    
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
    //    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    //        layout.estimatedItemSize = CGSize(width: view.bounds.size.width, height: 10)
    //        layout.invalidateLayout()
    //        super.viewWillTransition(to: size, with: coordinator)
    //    }
    
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
