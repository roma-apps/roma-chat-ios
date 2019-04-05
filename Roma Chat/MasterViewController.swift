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

enum ConversationScreenType {
    case ConversationList
    case Conversation
}

enum SizeModification {
    case Collapse
    case Expand
}

class MasterViewController: UIViewController, UIScrollViewDelegate, ProfileScreenDelegate {
    
    @IBOutlet weak var conversationContainerView: UIView!
    
    @IBOutlet weak var conversationListTableView: UITableView!
    
    @IBOutlet weak var transparentView: UIView!
    @IBOutlet weak var feedContainerView: UIView!
    
    @IBOutlet weak var masterContainerView: UIView!
    
    @IBOutlet weak var screenContainerScrollView: UIScrollView!
    
    @IBOutlet weak var profileScreen: ProfileScreen!
    @IBOutlet weak var conversationScreen: ConversationScreen!
    
    @IBOutlet weak var conversationContainerScrollView: UIScrollView!
    
    @IBOutlet weak var cnstCollapseTransparentView: NSLayoutConstraint!
    @IBOutlet weak var cnstExpandTransparentView: NSLayoutConstraint!
    
    
    let priorityEnabled : Float = 999.0
    let priorityDisabled : Float = 1.0
    
    let conversationList = ConversationListScreen()
    
    //MARK: - App Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        screenContainerScrollView.delegate = self
        screenContainerScrollView.contentInsetAdjustmentBehavior = .never
        
        // Init Conversation List
        conversationListTableView.contentInset = UIEdgeInsets(top: 60.0, left: 0, bottom: 0, right: 0)
        conversationListTableView.delegate = conversationList
        conversationListTableView.dataSource = conversationList
        conversationListTableView.register(UINib(nibName: "ConversationListCell", bundle: nil), forCellReuseIdentifier: "ConversationListCell")
        fetchInitialData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initViews()
    }
    
    private func initViews() {
        moveToScreen(screen: .Transparent, animated: false)
        showConversationScreen(.ConversationList, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: - Data Fetch
    
    private func fetchInitialData() {
        ApiManager.shared.fetchConversations { [weak self] in
            DispatchQueue.main.async {
                self?.conversationList.initData(StoreStruct.conversations)
                self?.conversationListTableView.reloadData()
            }
        }
    }
    
    //MARK: - Main Screen Actions
    
    @IBAction func btnConversationClicked(_ sender: UIButton) {
        let currentPage = page(scrollView: screenContainerScrollView)
        if currentPage == .Conversation { return }
        
        //If on Feed screen, Collapse Transparent view first
        if currentPage == .Feed { modifyTransparentViewWidth(action: .Collapse, andUpdate: true) }
        
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
        
        //If on Conversation screen, Collapse Transparent view first
        if currentPage == .Conversation { modifyTransparentViewWidth(action: .Collapse, andUpdate: true) }

        moveToScreen(screen: .Feed, animated: true)
    }
    
    
    @IBAction func btnProfileClicked(_ sender: UIButton) {
        //Use a helper to hanlde this & animate
        
        profileScreen.isHidden = false
        profileScreen.delegate = self
    }
    
    func closeProfileScreen() {
        profileScreen.isHidden = true
    }
    
    func openSettingsScreen() {
        let settingsScreen = Storyboard.shared.storyboard.instantiateViewController(withIdentifier: Storyboard.settingsViewController) as! SettingsViewController
        self.navigationController?.pushViewController(settingsScreen, animated: true)
    }
    
    //MARK: - View modifications
    
    private func showConversationScreen(_ type: ConversationScreenType, animated: Bool) {
        let pageWidth : CGFloat = conversationContainerView.frame.width
        let targetPage :CGFloat = ( type == .ConversationList) ? 1.0 :  0.0
        let slideToX = pageWidth * targetPage
        
        self.view.layoutIfNeeded()
        self.conversationContainerScrollView.setContentOffset(CGPoint(x: slideToX, y:0), animated: animated)
    }
    
    //MARK: - Pagination and Scrolling
    
    private func page (scrollView: UIScrollView) -> ScreenType {
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
    
    private func moveToScreen (screen: ScreenType, animated: Bool) {
        let pageWidth : CGFloat = conversationContainerView.frame.width
        var targetPage :CGFloat = 0.0

        if !isTransparentViewExpanded() {
            switch screen {
            case .Conversation:
                targetPage = 0
            case .Transparent:
                return  //this should never happen
            case .Feed:
                // The total number of pages is 2 in this case
                targetPage = 1.0
            }
        } else {
            switch screen {
            case .Conversation:
                targetPage = 0
            case .Transparent:
                targetPage = 1.0
            case .Feed:
                targetPage = 2.0
            }
        }

        let slideToX = pageWidth * targetPage
        
        self.view.layoutIfNeeded()
        self.screenContainerScrollView.setContentOffset(CGPoint(x: slideToX, y:0), animated: true)
    }
    
    private func modifyTransparentViewWidth(action: SizeModification, andUpdate: Bool) {
        self.view.layoutIfNeeded() //Finish animations before action
        switch action {
        case .Collapse:
            if isTransparentViewExpanded() {
                cnstExpandTransparentView.priority = UILayoutPriority(rawValue: priorityDisabled)
                cnstCollapseTransparentView.priority = UILayoutPriority(rawValue: priorityEnabled)
                if andUpdate { self.view.layoutIfNeeded() }
            }
        case .Expand:
            if !isTransparentViewExpanded() {
                cnstExpandTransparentView.priority = UILayoutPriority(rawValue: priorityEnabled)
                cnstCollapseTransparentView.priority = UILayoutPriority(rawValue: priorityDisabled)
                if andUpdate { self.view.layoutIfNeeded() }
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
        
        /// Just reached target page, expand transparent view and readjust content offset
        if page(scrollView: screenContainerScrollView) == .Feed {
            if !isTransparentViewExpanded() { modifyTransparentViewWidth(action: .Expand, andUpdate: false) }

            let setToX = conversationContainerView.frame.width * 2.0
            self.screenContainerScrollView.setContentOffset(CGPoint(x: setToX, y:0), animated: false)
            
            if conversationContainerScrollView.contentOffset.x == 0 { showConversationScreen(.ConversationList, animated: false) } //Reset Conversation container scroll view
        } else if page(scrollView: screenContainerScrollView) == .Transparent {
            //No need to check if transparent view is expanded since we just reached transparent view.
            
            if conversationContainerScrollView.contentOffset.x == 0 { showConversationScreen(.ConversationList, animated: false) } //Reset Conversation container scroll view
        } else {
            if !isTransparentViewExpanded() { modifyTransparentViewWidth(action: .Expand, andUpdate: true) }
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
