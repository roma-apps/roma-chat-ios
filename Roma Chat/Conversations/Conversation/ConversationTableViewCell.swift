//
//  ConversationTableViewCell.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-06-13.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//


import UIKit

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
    
    
    func formatDateToString(date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: date, to: now).day
        let months = calendar.dateComponents([.month], from: date, to: now).month
        
        let dateFormatter = DateFormatter()
        
        if let months = months, months > 0 {
            //            return "\(months)m"
            dateFormatter.dateFormat = "MMM dd,yyyy"
            return dateFormatter.string(from: date)
        } else if let days = days, days > 0 {
            if days < 7 {
                let myCalendar = Calendar(identifier: .gregorian)
                let weekDay = myCalendar.component(.weekday, from: date)
                return dateFormatter.weekdaySymbols[weekDay]
            } else if days > 7 {
                dateFormatter.dateFormat = "MMM dd,yyyy"
                return dateFormatter.string(from: date)
            }
        }
        
        return "Today"
    }
}
