//
//  Storyboard.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-03-25.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import UIKit

struct Storyboard {
    
    //TODO: move the long view controller instantiation into functions in this struct
    
    init(){ }
    
    static var shared = Storyboard()
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    //UIViewControllers
    static var landingNavigationController = "LandingNavigationController"
    static var landingViewController = "LandingViewController"
    static var masterNavigationController = "MasterNavigationController"
    static var masterViewController = "MasterViewController"
    static var settingsViewController = "SettingsViewController"
    static var conversationViewController = "ConversationViewController"

    //UIViews
    static var profileView = "ProfileView"

    //Cells
    static var settingsTableViewCell = "SettingsTableViewCell"


    
    /*
 //Use a helper to hanlde this
 if let profileView = Bundle.main.loadNibNamed(Storyboard.profileView, owner: self, options: nil)?.first as? ProfileView {
 */
}
