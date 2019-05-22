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
    
    var avatar : UIImage?
    
    var conversation: RomaConversation?
    
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
        
        conversationCollectionView.keyboardDismissMode = .onDrag
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
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
            var keyboardHeight = keyboardSize.height
                self.fakeKeyboardHeightCnst.constant = keyboardHeight
                self.view.layoutIfNeeded()
                print("keyboard height: \(keyboardHeight)")
                
//            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.view.frame.origin.y != 0 {
            var keyboardHeight = keyboardSize.height
            if keyboardHeight > 0 {
                keyboardHeight -= 58
            }
                self.fakeKeyboardHeightCnst.constant = keyboardHeight
                self.view.layoutIfNeeded()
                print("keyboard height: \(keyboardSize.height)")

//            }
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
        self.view.endEditing(true)
    }
    //    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    //        layout.estimatedItemSize = CGSize(width: view.bounds.size.width, height: 10)
    //        layout.invalidateLayout()
    //        super.viewWillTransition(to: size, with: coordinator)
    //    }
}
