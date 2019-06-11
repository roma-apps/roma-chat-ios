//
//  FeedCell.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-06-11.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import UIKit

class FeedCell: UITableViewCell {
    
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    
    @IBOutlet weak var imgAvatar: UIImageView!
    //    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//
    @IBOutlet weak var lblTime: UILabel!
    //
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
}
