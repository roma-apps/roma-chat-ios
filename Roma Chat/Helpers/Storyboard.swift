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
    static var masterPageNavigationViewController = "MasterPageViewController"
    static var masterPageViewController = "MasterPageViewController"
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

protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

extension StoryboardIdentifiable where Self: UIViewController {
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
}

extension UIViewController: StoryboardIdentifiable { }

extension UIStoryboard {
    //  If there are multiple storyboards in the project, each one must be named here:
    enum Storyboard: String {
        case main = "Main"
    }
    
    convenience init(storyboard: Storyboard, bundle: Bundle? = nil) {
        self.init(name: storyboard.rawValue, bundle: bundle)
    }
    
    class func storyboard(storyboard: Storyboard, bundle: Bundle? = nil) -> UIStoryboard {
        return UIStoryboard(name: storyboard.rawValue, bundle: bundle)
    }
    
    func instantiateViewController<T: UIViewController>() -> T {
        guard let viewController = instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
            fatalError("Could not find view controller with name \(T.storyboardIdentifier)")
        }
        
        return viewController
    }
}

/// Use in view controllers:
///
/// 1) Have view controller conform to SegueHandlerType
/// 2) Add `enum SegueIdentifier: String { }` to conformance
/// 3) Manual segues are trigged by `performSegue(with:sender:)`
/// 4) `prepare(for:sender:)` does a `switch segueIdentifier(for: segue)` to select the appropriate segue case

protocol SegueHandlerType {
    associatedtype SegueIdentifier: RawRepresentable
}

extension SegueHandlerType where Self: UIViewController, SegueIdentifier.RawValue == String {
    func performSegue(withIdentifier identifier: SegueIdentifier, sender: Any?) {
        performSegue(withIdentifier: identifier.rawValue, sender: sender)
    }
    
    func segueIdentifier(for segue: UIStoryboardSegue) -> SegueIdentifier {
        guard let identifier = segue.identifier,
            let segueIdentifier = SegueIdentifier(rawValue: identifier)
            else {
                fatalError("Invalid segue identifier: \(String(describing: segue.identifier))")
        }
        
        return segueIdentifier
    }
}
