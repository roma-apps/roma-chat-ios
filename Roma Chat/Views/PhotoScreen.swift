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
}

class PhotoScreen: UIView {
    
    var image: UIImage?
    
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
        self.imgView.image = image
        self.view.layoutIfNeeded()
    }
    
    @IBAction func btnCloseClicked(_ sender: UIButton) {
        self.delegate?.closePhotoScreen()
        
    }
    
    
}
