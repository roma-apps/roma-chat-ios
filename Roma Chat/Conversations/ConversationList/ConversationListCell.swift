//
//  ConversationListCell.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-03-20.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import UIKit

class ConversationListCell: UITableViewCell {
    
    
    @IBOutlet weak var imgAvatarView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    
    @IBOutlet weak var iconConversationStatus: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconConversationStatus.layer.borderWidth = 1.0
        iconConversationStatus.layer.borderColor = UIColor.lightGray.cgColor
        
    }
}
