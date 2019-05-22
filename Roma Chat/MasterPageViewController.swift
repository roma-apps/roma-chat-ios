//
//  MasterPageViewController.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-05-02.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import Foundation
import UIKit

class MasterPageViewController: UIPageViewController {

    private let screens = ["Conversation", "MasterViewController"]

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        setViewControllers([viewControllerForPage(at: 0)], direction: .forward, animated: false, completion: nil)
    }
}

// MARK: Page view controller data source

extension MasterPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? MasterViewController,
             viewController.pageIndex > 0  else {
                return nil
        }
        return viewControllerForPage(at: viewController.pageIndex - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? MasterViewController,
             viewController.pageIndex + 1 < screens.count else {
                return nil
        }
        return viewControllerForPage(at: viewController.pageIndex + 1)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return screens.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let viewControllers = pageViewController.viewControllers, let currentVC = viewControllers.first as? MasterViewController else { return 0 }
        
        return currentVC.pageIndex
    }
    
    private func viewControllerForPage(at index: Int) -> UIViewController {
        if index == 0 {
            guard let masterNavigationController = Storyboard.shared.storyboard.instantiateViewController(withIdentifier: Storyboard.masterNavigationController) as? MasterNavigationController else { return UIViewController() }
            //        cardViewController.pageIndex = index
            //        cardViewController.screens = screens[index]
            return masterNavigationController
        } else {
            guard let conversationController = Storyboard.shared.storyboard.instantiateViewController(withIdentifier: Storyboard.conversationViewController) as? ConversationViewController else { return UIViewController() }
            //        cardViewController.pageIndex = index
            //        cardViewController.screens = screens[index]
            return conversationController
        }

    }
}
