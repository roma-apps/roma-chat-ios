//
//  ProfileScreen.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-03-28.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

/*
 To replicate using a Xib UIView with a code side implementation in another Xib or the Storyboard follow these steps:
 
 1) Create a .swift file named ____.
 
 2) Ensure _____ inherits UIView or whatever you're trying to inherit.
 This ProfieScreen inherits UIView because that is the reusable element we are creating.
 
 3) Create a View file named _____ (should be identical to swift file name).
 
 4) Set the File Owner class name in the XIB file to _____.
 
 5) Add a UIView inside that XIB file as a subview, then add your elements as subviews of that UIView,
 constrain them as you wish, and connect the outlets as you wish to the .swift equivallent.
 
 6) Copy and paste the following into the .swift file replacing instances of "ProfileScreen" with your class name
 
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
 
     let nib = UINib.init(nibName: String(describing: ProfileScreen.self), bundle: nil)
     let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
 
     return view
     }
 
     override func awakeFromNib() {
     super.awakeFromNib()

        // Do what you want with your Outlets here (this is like your viewDidLoad method for UIViewControllers)
 
     }
 
 7) In your storybaord or other XIB file where you wish to use the view you just created. Create a new UIView.
 Constrain that UIView so it has no conflicts. And in its properties, set the Class name to _____.
 
 You may now use that view any way you would normally use a UIKit view in your storybaord. It should load as all others do.
 
 
 */


import UIKit

protocol ProfileScreenDelegate: AnyObject {
    func closeProfileScreen()
}

class ProfileScreen: UIView {
    
    weak var delegate: ProfileScreenDelegate?

    @IBOutlet weak var lblAccountName: UILabel!
    
    // Our custom view from the XIB file
    var view: UIView!
    
    lazy var instances = [InstanceData]()
    lazy var accounts = [Account]()
    
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
        
        let nib = UINib.init(nibName: String(describing: ProfileScreen.self), bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView

        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        instances = InstanceData.getAllInstances()
        accounts = Account.getAccounts()
        //TODO: use current instance to determine corresponding account
        let account = accounts[0]
        
        lblAccountName.text = account.username
        
    }
    
    @IBAction func btnClosePressed(_ sender: UIButton) {
        self.delegate?.closeProfileScreen()
    }
    
    
    @IBAction func btnSettingsPressed(_ sender: UIButton) {
        
    }
    
}
