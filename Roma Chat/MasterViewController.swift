//
//  MasterViewController.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-03-11.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import UIKit

enum ScreenType {
    case Conversation
    case Feed
    case Transparent
}

enum SizeModification {
    case Collapse
    case Expand
}

class MasterViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var conversationContainerView: UIView!
    @IBOutlet weak var transparentView: UIView!
    @IBOutlet weak var feedContainerView: UIView!
    
    
    @IBOutlet weak var masterContainerView: UIView!
    
    @IBOutlet weak var screenContainerScrollView: UIScrollView!
    
    
    @IBOutlet weak var cnstCollapseTransparentView: NSLayoutConstraint!
    @IBOutlet weak var cnstExpandTransparentView: NSLayoutConstraint!
    
    let priorityEnabled : Float = 999.0
    let priorityDisabled : Float = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        screenContainerScrollView.delegate = self
        screenContainerScrollView.contentInsetAdjustmentBehavior = .never
        
        //TODO: Add and init the Conversation UIView and populate with real data
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        moveToScreen(screen: .Transparent, animated: false)
    }
    
    @IBAction func btnConversationClicked(_ sender: UIButton) {
        let currentPage = page(scrollView: screenContainerScrollView)
        if currentPage == .Conversation { return }
        moveToScreen(screen: .Conversation, animated: true)
    }
    
    @IBAction func btnCameraClicked(_ sender: UIButton) {
        let currentPage = page(scrollView: screenContainerScrollView)
        if currentPage == .Transparent { return }
        
        moveToScreen(screen: .Transparent, animated: true)
    }
    
    @IBAction func btnFeedClicked(_ sender: UIButton) {
        let currentPage = page(scrollView: screenContainerScrollView)
        if currentPage == .Feed { return }
        
        moveToScreen(screen: .Feed, animated: true)
    }
    
    
    //MARK: - Pagination and Scrolling
    
    func page (scrollView: UIScrollView) -> ScreenType {
        let width = scrollView.frame.width
        let pageNumber = scrollView.contentOffset.x / width
        if !isTransparentViewExpanded() {
            if pageNumber == 0 { return .Conversation }
            else if pageNumber == 1 { return .Feed }
            else {
                return .Conversation
            }
        } else {
            if pageNumber == 0 { return .Conversation }
            else if pageNumber == 1 { return .Transparent }
            else if pageNumber == 2 { return .Feed }
            else {
                return .Transparent
            }
        }
    }
    
    func pageAssuming2Pages (scrollView: UIScrollView) -> ScreenType {
        let width = scrollView.frame.width
        let pageNumber = scrollView.contentOffset.x / width
        if pageNumber == 0 { return .Conversation }
        else if pageNumber == 1 { return .Feed }
        else {
            return .Conversation
        }

    }
    
    func moveToScreen (screen: ScreenType, animated: Bool) {
        let pageWidth : CGFloat = conversationContainerView.frame.width

        var targetPage :CGFloat = 0.0

        if !isTransparentViewExpanded() {
            
            switch screen {
            case .Conversation:
                targetPage = 0
            case .Transparent:
                modifyTransparentViewWidth(action: .Expand) //This will change the total number of pages to 3
                
                // Special case: if transitioning from Feed to Transparent view, content offset must be adjust for newly expanded scrollview
                if pageAssuming2Pages(scrollView: screenContainerScrollView) == .Feed {
                    let setToX = pageWidth * 2.0
                    self.screenContainerScrollView.setContentOffset(CGPoint(x: setToX, y:0), animated: false)
                }

                targetPage = 1.0
            case .Feed:
                // The total number of pages is 2 in this case
                targetPage = 1.0
            }
        } else {
            switch screen {
            case .Conversation:
                targetPage = 0
            case .Transparent:
                modifyTransparentViewWidth(action: .Expand) //This case should never happen
                targetPage = 1.0
            case .Feed:
                targetPage = 2.0
            }
        }

        let slideToX = pageWidth * targetPage
        
        self.view.layoutIfNeeded()
        self.screenContainerScrollView.setContentOffset(CGPoint(x: slideToX, y:0), animated: true)
    }
    
    func modifyTransparentViewWidth(action: SizeModification) {
        self.view.layoutIfNeeded() //Finish animations before action
        switch action {
        case .Collapse:
            if isTransparentViewExpanded() {
                cnstExpandTransparentView.priority = UILayoutPriority(rawValue: priorityDisabled)
                cnstCollapseTransparentView.priority = UILayoutPriority(rawValue: priorityEnabled)
                self.view.layoutIfNeeded()
            }
        case .Expand:
            if !isTransparentViewExpanded() {
                cnstExpandTransparentView.priority = UILayoutPriority(rawValue: priorityEnabled)
                cnstCollapseTransparentView.priority = UILayoutPriority(rawValue: priorityDisabled)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func isTransparentViewExpanded() -> Bool {
        if transparentView.frame.width > 10 {
            return true
        }
        
        return false
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        /// Shrink the width of the transparent view after the scrollview has animated so if the user toggles between Conversation List and Feed the trasnsparent view does not appear
        
        /// Just reached target page
        
        switch page(scrollView: scrollView) {
        case .Conversation:
            modifyTransparentViewWidth(action: .Collapse)
        case .Transparent:
            return
        case .Feed:
            modifyTransparentViewWidth(action: .Collapse)
        }
    }
    
    /*
     * default function called when view is scolled. In order to enable callback
     * when scrollview is scrolled, the below code needs to be called:
     * slideScrollView.delegate = self or
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        //
        //        let maximumHorizontalOffset: CGFloat = scrollView.contentSize.width - scrollView.frame.width
        //        let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
        //
        //        // vertical
        //        let maximumVerticalOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.height
        //        let currentVerticalOffset: CGFloat = scrollView.contentOffset.y
        //
        //        let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset
        //        let percentageVerticalOffset: CGFloat = currentVerticalOffset / maximumVerticalOffset
        //
        //
        /*
         * below code changes the background color of view on paging the scrollview
         */
        //        self.scrollView(scrollView, didScrollToPercentageOffset: percentageHorizontalOffset)
        
        
        /*
         * below code scales the imageview on paging the scrollview
         */
        //        let percentOffset: CGPoint = CGPoint(x: percentageHorizontalOffset, y: percentageVerticalOffset)
        //
        //        if(percentOffset.x > 0 && percentOffset.x <= 0.33) {
        //
        //            conversationContainerView.transform = CGAffineTransform(scaleX: (0.33-percentOffset.x)/0.33, y: (0.33-percentOffset.x)/0.33)
        //            transparentView.transform = CGAffineTransform(scaleX: percentOffset.x/0.33, y: percentOffset.x/0.33)
        //
        //        } else if(percentOffset.x > 0.33 && percentOffset.x <= 0.66) {
        //            transparentView.transform = CGAffineTransform(scaleX: (0.66-percentOffset.x)/0.33, y: (0.66-percentOffset.x)/0.33)
        //            feedContainerView.transform = CGAffineTransform(scaleX: percentOffset.x/0.66, y: percentOffset.x/0.66)
        //
        //        } else if(percentOffset.x > 0.66 && percentOffset.x <= 1) {
        //            transparentView.transform = CGAffineTransform(scaleX: (1-percentOffset.x)/0.33, y: (0.75-percentOffset.x)/0.33)
        //            feedContainerView.transform = CGAffineTransform(scaleX: percentOffset.x/1, y: percentOffset.x/1)
        //        }
    }
    
}
