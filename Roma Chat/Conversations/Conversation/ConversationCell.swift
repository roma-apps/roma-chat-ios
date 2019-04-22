//
//  ConversationCell.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-04-04.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import UIKit

class ConversationCell: UICollectionViewCell {

    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var imgAvatarView: UIImageView!
    
    lazy var width: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor.red
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        width.constant = bounds.size.width
        return contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: 1))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setupViews() {
        if let lastSubview = contentView.subviews.last {
            contentView.bottomAnchor.constraint(equalTo: lastSubview.bottomAnchor, constant: 10).isActive = true
        }
    }
        
}
