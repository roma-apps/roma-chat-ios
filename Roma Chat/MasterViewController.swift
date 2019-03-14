//
//  MasterViewController.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-03-11.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController {
    
    @IBOutlet weak var conversationContainerView: UIView!
    
    //Constraints used to move Conversation Screen
    @IBOutlet weak var cnstConvScreenLeft: NSLayoutConstraint!
    @IBOutlet weak var cnstConvScreenRight: NSLayoutConstraint!
    
    var convViewIsLeft = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Init Constraints for sliding views
        cnstConvScreenLeft.priority = UILayoutPriority(999)
        cnstConvScreenRight.priority = UILayoutPriority(1)
        
        
        //TODO: Add and init the Conversation UIView and populate with real data
    }
    
    @IBAction func btnConversationClicked(_ sender: UIButton) {
        
        /// Move Conversation Screen right if conversation button is clicked and the conversation screen is on the left
        
        if convViewIsLeft {
            
            /// LayoutIfNeeded specifically needs to be called before and after the animation block to ensure the constraint change animates
            self.view.layoutIfNeeded()

            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
                self.cnstConvScreenLeft.priority = UILayoutPriority(1)
                self.cnstConvScreenRight.priority = UILayoutPriority(999)
                self.view.layoutIfNeeded()
            })
//            UIView.animate(withDuration: 0.1) {
//                self.cnstConvScreenLeft.priority = UILayoutPriority(1)
//                self.cnstConvScreenRight.priority = UILayoutPriority(999)
//                self.view.layoutIfNeeded()
//            }
            convViewIsLeft = false
        }
        
        //TODO: Animate and change all buttons on master display when animation happens, and vice versa
    }
    
    @IBAction func btnCameraClicked(_ sender: UIButton) {
        
        /// Move Conversation Screen left if camera button is clicked and the conversation screen is on the right
        
        if !convViewIsLeft {
            
            /// LayoutIfNeeded specifically needs to be called before and after the animation block to ensure the constraint change animates
            self.view.layoutIfNeeded()
//            UIView.animate(withDuration: 0.1) {
//                self.cnstConvScreenLeft.priority = UILayoutPriority(999)
//                self.cnstConvScreenRight.priority = UILayoutPriority(1)
//                self.view.layoutIfNeeded()
//            }
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                self.cnstConvScreenLeft.priority = UILayoutPriority(999)
                self.cnstConvScreenRight.priority = UILayoutPriority(1)
                self.view.layoutIfNeeded()
            })
            
            convViewIsLeft = true
        }
    }
    
    //MARK: - Helpers
    
}
