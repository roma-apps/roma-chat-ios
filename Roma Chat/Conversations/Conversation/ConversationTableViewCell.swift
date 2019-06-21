//
//  ConversationTableViewCell.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-06-13.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//


import UIKit

protocol ConversationTableViewCellDelegate: AnyObject {
    func imageClicked(indexPath: IndexPath)
}

class ConversationTableViewCell: UITableViewCell {

    @IBOutlet weak var dateContainer: UIView!
    @IBOutlet weak var cnstDateContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var lblDate: UILabel!
    
    
    @IBOutlet weak var nameContainer: UIView!
    @IBOutlet weak var cnstNameContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var lblName: UILabel!
    
    
    @IBOutlet weak var leftLine: UIView!
    @IBOutlet weak var lblMessage: UILabel!
    
    let lightBlueColor = UIColor(red:0.20, green:0.68, blue:0.97, alpha:1.0)
    
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var cnstHideImageView: NSLayoutConstraint!
    @IBOutlet weak var cnstShowImageView: NSLayoutConstraint!
    @IBOutlet weak var viewImgContainer: UIView!
    
    var indexPath: IndexPath?
    weak var delegate: ConversationTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setDate(date: Date?, show: Bool) {
        if show, let date = date {
            let dateString = formatDateToString(date: date)
            dateContainer.isHidden = false
            cnstDateContainerHeight.constant = 30
            lblDate.text = dateString
        } else {
            dateContainer.isHidden = true
            cnstDateContainerHeight.constant = 0
        }
        
        self.layoutIfNeeded()

    }
    
    func setName(name: String, show: Bool) {
        if show {
            nameContainer.isHidden = false
            cnstNameContainerHeight.constant = 30
            lblName.text = name
        } else {
            nameContainer.isHidden = true
            cnstNameContainerHeight.constant = 0
        }
        
        self.layoutIfNeeded()

    }
    
    func setupForCurrentUser(currentUser: Bool) {
        if currentUser {
            leftLine.backgroundColor = .red
            lblName.text = "ME"
            lblName.textColor = .red
        } else {
            leftLine.backgroundColor = lightBlueColor
            lblName.text = lblName.text?.uppercased()
            lblName.textColor = lightBlueColor
        }
        self.layoutIfNeeded()
    }
    
    func showImage(attachment: Attachment) {
        toggleAttachmentsView(hide: false)
        ApiManager.shared.fetchThumbnailForAttachment(attachment: attachment) { (image) in
            DispatchQueue.main.async { [weak self] in
                self?.imgThumbnail.image = image
                self?.layoutIfNeeded()
//                imageCache.setObject(image, forKey: self.avatar as AnyObject)
//                completion(image)
            }
        }
    }
    
    func toggleAttachmentsView(hide: Bool) {
        if hide {
            self.cnstShowImageView.priority = UILayoutPriority(rawValue: 200)
            self.cnstHideImageView.priority = UILayoutPriority(rawValue: 900)
            self.viewImgContainer.isHidden = true
        } else {
            self.cnstShowImageView.priority = UILayoutPriority(rawValue: 900)
            self.cnstHideImageView.priority = UILayoutPriority(rawValue: 200)
            self.viewImgContainer.isHidden = false
        }
        
        self.layoutIfNeeded()
    }
    
    
    
    func formatDateToString(date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: date, to: now).day
        let months = calendar.dateComponents([.month], from: date, to: now).month
        
        let dateFormatter = DateFormatter()
        
        if let months = months, months > 0 {
            //            return "\(months)m"
            dateFormatter.dateFormat = "MMM dd, yyyy"
            return dateFormatter.string(from: date)
        } else if let days = days, days > 0 {
            if days < 7 {
                let myCalendar = Calendar(identifier: .gregorian)
                let weekDay = myCalendar.component(.weekday, from: date)
                return dateFormatter.weekdaySymbols[weekDay]
            } else if days >= 7 {
                dateFormatter.dateFormat = "MMM dd, yyyy"
                return dateFormatter.string(from: date)
            }
        }
        
        return "Today"
    }
    
    @IBAction func btnThumbnailClicked(_ sender: Any) {
        guard let indexPath = self.indexPath else { return }
        
        self.delegate?.imageClicked(indexPath: indexPath)
    }
}
