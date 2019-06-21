//
//  PhotoScreen.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-04-09.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import Foundation
import UIKit

protocol PhotoScreenDelegate: AnyObject {
    func closePhotoScreen()
    func showSendToFriendScreen()

}

class PhotoScreen: UIView {
    
    var image: UIImage?
    
    var conversationsData : [RomaConversation]?

    weak var delegate: PhotoScreenDelegate?

    @IBOutlet weak var imgView: UIImageView!
    // Our custom view from the XIB file
    var view: UIView!
    
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
        
        let nib = UINib.init(nibName: String(describing: PhotoScreen.self), bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func refreshWithImage(image: UIImage) {
        
//        let newImg = scaleUIImageToSize(image: image, size: self.imgView.frame.size)
        self.imgView.image = image

        self.view.layoutIfNeeded()
    }
    
    @IBAction func btnCloseClicked(_ sender: UIButton) {
        self.delegate?.closePhotoScreen()
        
    }
    
    func scaleUIImageToSize(image: UIImage, size: CGSize) -> UIImage {
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    
    @IBAction func sendBtnClicked(_ sender: UIButton) {
        
        self.delegate?.showSendToFriendScreen()
        
    }
    
    func sendSavedImage(toFriend: Account?) {
        if let account = toFriend {
            guard let image = self.imgView.image else { return }
            sendImage(image: image, toUser: account.username)
        } else {
            //error
        }
    }
    
    func sendImage(image: UIImage, toUser: String) {
        
        let compression: CGFloat = 1
        var mediaIDs: [String] = []

        let imageData = (image).jpegData(compressionQuality: compression)
        let request = Media.upload(media: .jpeg(imageData))
        StoreStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                mediaIDs.append(stat.id)
                let request7 = Media.updateDescription(description: "", id: stat.id)
                
                //TODO: this looks odd running this second request
                StoreStruct.client.run(request7) { (statuses) in
                    
                }
                
                let attachmentMessage = "@\(toUser)"

                ApiManager.shared.sendDirectMessageStatusForMediaAttachment(message: attachmentMessage, mediaIDs: mediaIDs)
                
                
//                let sender = Sender(id: "1", displayName: "\(StoreStruct.currentUser.acct)")
//                let x = MockMessage.init(image: StoreStruct.photoNew, sender: sender, messageId: "18982", date: Date())
//
//                let request0 = Statuses.create(status: "@\(self.lastUser)", replyToID: self.mainStatus[0].id, mediaIDs: mediaIDs, sensitive: self.mainStatus[0].sensitive, spoilerText: StoreStruct.spoilerText, scheduledAt: nil, poll: nil, visibility: .direct)
//                StoreStruct.client.run(request0) { (statuses) in
//
//                    DispatchQueue.main.async {
//                        if let stat = statuses.value {
//                            self.allPosts.append(stat)
//                            self.messages.append(x)
//                            self.messagesCollectionView.reloadData()
//                            self.messagesCollectionView.scrollToBottom()
//                        }
//                    }
//                }
            }
        }
    }
    
    
}
