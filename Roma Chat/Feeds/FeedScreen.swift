//
//  FeedScreen.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-06-11.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import UIKit


//TODO: Depreceated

class FeedScreen: UIView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblView: UITableView!
    
    private let reuseIdentifier = "FeedCell"
    
    
    public var statuses: [Status]?
    
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
        
        let nib = UINib.init(nibName: String(describing: FeedScreen.self), bundle: nil)
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
        
        tblView.dataSource = self
        tblView.delegate = self
//        conversationCollectionView.collectionViewLayout = layout
//        conversationCollectionView.alwaysBounceVertical = true
//        conversationCollectionView.contentInsetAdjustmentBehavior = .always
        tblView.register(UINib(nibName: "FeedCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        tblView.rowHeight = UITableView.automaticDimension
        tblView.estimatedRowHeight = 44
    }
    
    func refreshData() {
//        guard let conversation = conversation else { return }
//
//        for message in conversation.messages {
//            if let status = message {
//                print("Meessage: \(String(describing: status.content))")
//            }
//        }
        
        
        
        tblView.reloadData()
//        let lastMessageIndex = conversation.messages.count - 1
//        conversationCollectionView.scrollToItem(at: IndexPath(row: lastMessageIndex, section: 0), at: UICollectionView.ScrollPosition.bottom, animated: true)
    }
    
    
    //MARK: - UITableViewDelegate & UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let statuses = statuses {
            return statuses.count
        }
        return 0
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? FeedCell {
            if let statuses = statuses {
                if statuses.count > indexPath.row {
                    let thisStatus = statuses[indexPath.row]
                    cell.lblTitle?.text = thisStatus.account.username.stripHTML()
                    cell.lblContent?.text = thisStatus.content.stripHTML()
                    thisStatus.account.getCachedAvatarImage { (avatarImage) in
                        //refresh cell image if cell is visible
                        DispatchQueue.main.async {
                            cell.imgAvatar.image = avatarImage
                            cell.reloadInputViews()
                        }
                    }
                    
                    cell.lblTime?.text = convertToTimeSinceNowString(date: thisStatus.createdAt)
                } else {
                    return UITableViewCell()
                    
                }
            
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    //TODO: extend date and add this
    func convertToTimeSinceNowString(date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: date, to: now).day
        let years = calendar.dateComponents([.year], from: date, to: now).year
        let months = calendar.dateComponents([.month], from: date, to: now).month
        let hours = calendar.dateComponents([.hour], from: date, to: now).hour
        let minutes = calendar.dateComponents([.minute], from: date, to: now).minute
        let seconds = calendar.dateComponents([.second], from: date, to: now).second
        if let years = years, years > 0 {
            return "\(years)y"
        } else if let months = months, months > 0 {
            return "\(months)m"
        } else if let days = days, days > 0 {
            return "\(days)d"
        } else if let hours = hours, hours > 0 {
            return "\(hours)h"
        } else if let minutes = minutes, minutes > 0 {
            return "\(minutes)m"
        } else if let seconds = seconds, seconds > 0 {
            return "\(seconds)s"
        }
        return ""
    }
}
