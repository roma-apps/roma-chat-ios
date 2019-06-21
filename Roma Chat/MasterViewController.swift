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

enum FeedScreenType {
    case Home
    case Public
    case Local
}

enum ConversationScreenType {
    case ConversationList
    case Conversation
}

enum SizeModification {
    case Collapse
    case Expand
}

class MasterViewController: UIViewController, UIScrollViewDelegate, ProfileScreenDelegate, ConversationListScreenDelegate, CameraViewDelegate, PhotoScreenDelegate, SendToFriendScreenDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var conversationContainerView: UIView!
    
    @IBOutlet weak var conversationListTableView: UITableView!
    
    @IBOutlet weak var transparentView: UIView!
    @IBOutlet weak var feedContainerView: UIView!
    
    @IBOutlet weak var masterContainerView: UIView!
    
    @IBOutlet weak var screenContainerScrollView: UIScrollView!
    @IBOutlet weak var conversationListScreen: UIView!
    
    @IBOutlet weak var profileScreen: ProfileScreen!
    
    @IBOutlet weak var cnstCollapseTransparentView: NSLayoutConstraint!
    @IBOutlet weak var cnstExpandTransparentView: NSLayoutConstraint!
    
    @IBOutlet weak var conversationListLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var cameraView: CameraView!
    @IBOutlet weak var photoScreen: PhotoScreen!
    @IBOutlet weak var screenContainerView: UIView!
    @IBOutlet weak var emptyConversationList: UIView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var backgroundColorView:UIView!
    @IBOutlet weak var navHeightConstraint:NSLayoutConstraint!
    
    @IBOutlet weak var feedScrollView: UIScrollView!
    
    @IBOutlet weak var feedTableContainer: UIView!
    @IBOutlet weak var homeFeedScreen: FeedScreen!
    @IBOutlet weak var publicFeedScreen: FeedScreen!
    @IBOutlet weak var localFeedScreen: FeedScreen!
    
    @IBOutlet weak var lblHome: UILabel!
    @IBOutlet weak var lblPublic: UILabel!
    @IBOutlet weak var lblLocal: UILabel!
    
    @IBOutlet weak var imgFeed: UIImageView!
    @IBOutlet weak var imgConversation: UIImageView!
    
    var pageIndex:Int = 0
    let priorityEnabled : Float = 999.0
    let priorityDisabled : Float = 1.0
    
    let conversationList = ConversationListScreen()
    
    var conversationViewController: ConversationViewController?
    
    var sendToFriendScreen: SendToFriendScreen?
    
    //MARK: - App Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        screenContainerScrollView.delegate = self
        screenContainerScrollView.contentInsetAdjustmentBehavior = .never
        
        feedScrollView.delegate = self
        feedScrollView.contentInsetAdjustmentBehavior = .never

        
        imgFeed.image = UIImage(named: "feed")!.withRenderingMode(.alwaysTemplate)
        imgFeed.tintColor = .white
        imgConversation.image = UIImage(named: "conversation")!.withRenderingMode(.alwaysTemplate)
        imgConversation.tintColor = .white
        
        // Init Conversation List
        conversationListTableView.contentInset = UIEdgeInsets(top: 60.0, left: 0, bottom: 0, right: 0)
        conversationListTableView.delegate = conversationList
        conversationListTableView.dataSource = conversationList
        conversationListTableView.register(UINib(nibName: "ConversationListCell", bundle: nil), forCellReuseIdentifier: "ConversationListCell")
        conversationList.delegate = self
        
        cameraView.delegate = self
        photoScreen.delegate = self
        
        
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = .white
        
        fetchInitialData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(conversationsRefreshed(_:)), name: .init("conversations_refreshed"), object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initViews()
    }
    
    private func initViews() {
        modifyBackgroundColor(visible: false)
        moveToScreen(screen: .Transparent, animated: false)
//        showConversationScreen(.ConversationList, animated: false)
        self.conversationList.conversationListScreen = self.conversationListScreen
        self.conversationList.tableView = self.conversationListTableView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: - Data Fetch
    
    private func fetchInitialData() {
        conversationListLoadingIndicator.isHidden = false
        conversationListLoadingIndicator.startAnimating()
        ApiManager.shared.fetchConversations { [weak self] error in
            Stream.shared.initStreams()

            DispatchQueue.main.async {
                let conversations = StoreStruct.conversations
                if conversations.isEmpty {
                    //display empty table
                    self?.emptyConversationList.isHidden = false
                    self?.conversationListLoadingIndicator.stopAnimating()
                    self?.conversationListLoadingIndicator.isHidden = true
                    if let error = error {
                        let alert = UIAlertController.init(title: "Conversation Fetch Error", message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self?.navigationController?.present(alert, animated: true, completion: nil)
                    }
                    return
                }
                self?.emptyConversationList.isHidden = true
                self?.conversationList.initData(conversations)
                self?.conversationListTableView.reloadData()
                self?.conversationList.setupViews() //This needs to be done after the initial data fetch to ensure the table size is taken into account
                self?.conversationListLoadingIndicator.stopAnimating()
                self?.conversationListLoadingIndicator.isHidden = true

            }
        }
        
        ApiManager.shared.fetchHomeTimelines { [weak self] in
            
            DispatchQueue.main.async {
                self?.homeFeedScreen.statuses = StoreStruct.statusesHome
                self?.homeFeedScreen.refreshData()
            }
        }
        
        ApiManager.shared.fetchPublicTimelines { [weak self] in
            
            DispatchQueue.main.async {
                self?.publicFeedScreen.statuses = StoreStruct.statusesFederated
                self?.publicFeedScreen.refreshData()
            }
        }
    }
    
    
    @objc func conversationsRefreshed(_ notification: Notification) {
        
        print("conversations refreshed")
        
        let conversations = StoreStruct.conversations
        if conversations.isEmpty {
            //display empty table
            DispatchQueue.main.async {
                self.emptyConversationList.isHidden = false
                self.conversationListLoadingIndicator.stopAnimating()
                self.conversationListLoadingIndicator.isHidden = true
                return
            }

        }
        DispatchQueue.main.async {
            self.emptyConversationList.isHidden = true
            self.conversationList.initData(conversations)
            self.conversationListTableView.reloadData()
            self.conversationList.setupViews() //This needs to be done after the initial data fetch to ensure the table size is taken into account
            self.conversationListLoadingIndicator.stopAnimating()
            self.conversationListLoadingIndicator.isHidden = true
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
        if currentPage == .Transparent {
            #if targetEnvironment(simulator)
            // your simulator code
            #else
            cameraView.takePhoto()
            #endif
        } else {
            moveToScreen(screen: .Transparent, animated: true)
        }
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
    
    @IBAction func btnSwapCameraClicked(_ sender: UIButton){
        
        cameraView.swapCamera()
        
    }
    
    func closeProfileScreen() {
        profileScreen.isHidden = true
    }
    
    func openSettingsScreen() {
        let settingsScreen = Storyboard.shared.storyboard.instantiateViewController(withIdentifier: Storyboard.settingsViewController) as! SettingsViewController
        self.navigationController?.pushViewController(settingsScreen, animated: true)
    }
    
    func showSendToFriendScreen() {
        let sendToFriendScreen = Storyboard.shared.storyboard.instantiateViewController(withIdentifier: Storyboard.sendToFriendScreen) as! SendToFriendScreen
        sendToFriendScreen.delegate = self
        sendToFriendScreen.conversationsData = StoreStruct.conversations
        self.sendToFriendScreen = sendToFriendScreen
        self.navigationController?.present(self.sendToFriendScreen!, animated: true, completion: nil)
    }
    
    func friendClicked(conversation: RomaConversation) {
        closePhotoScreen()
        self.photoScreen.sendSavedImage(toFriend: conversation.user)
    }
    
    @IBAction func btnAddFriendClicked(_ sender: Any) {
        searchBar.resignFirstResponder()
    }
    
    
    //MARK: - Camera Actions
    
    func imageTaken(image: UIImage) {
        //display on screen
        DispatchQueue.main.async {
            self.photoScreen.refreshWithImage(image: image)
            self.photoScreen.isHidden = false
        }
    }
    
    func closePhotoScreen() {
        DispatchQueue.main.async {
            self.photoScreen.isHidden = true
        }
    }
    
    //MARK: - Conversation List Screen Delegate
    
    func conversationClicked(conversation: RomaConversation, avatar: UIImage?) {
        self.conversationViewController = Storyboard.shared.storyboard.instantiateViewController(withIdentifier: Storyboard.conversationViewController) as? ConversationViewController
        
        guard let conversationVC = self.conversationViewController else { return }
        
        conversationVC.conversation = conversation
        conversationVC.avatar = avatar
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        present(conversationVC, animated: false, completion: nil)
        
//        navigationController?.pushViewController(conversationVC, animated: true)

//        showConversationScreen(.Conversation, animated: true)
    }
    
    func refreshConversations(completion: @escaping () -> ()) {
        self.conversationListLoadingIndicator.isHidden = false
        self.conversationListLoadingIndicator.startAnimating()
        ApiManager.shared.fetchConversations { [weak self] error in
            DispatchQueue.main.async {
                let conversations = StoreStruct.conversations
                if conversations.isEmpty {
                    //display empty table
                    self?.emptyConversationList.isHidden = false
                    self?.conversationListLoadingIndicator.stopAnimating()
                    self?.conversationListLoadingIndicator.isHidden = true
                    if let error = error {
                        let alert = UIAlertController.init(title: "Conversation Fetch Error", message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self?.navigationController?.present(alert, animated: true, completion: nil)
                    }
                    completion()
                    return
                }
                self?.emptyConversationList.isHidden = true
                self?.conversationList.initData(conversations)
                self?.conversationListTableView.reloadData()
                self?.conversationList.setupViews() //This needs to be done after the data fetch to ensure the table size is taken into account
                self?.conversationListLoadingIndicator.stopAnimating()
                self?.conversationListLoadingIndicator.isHidden = true

                completion()
            }
        }
    }
    
    //MARK: - View modifications
    
//    private func showConversationScreen(_ type: ConversationScreenType, animated: Bool) {
//        let pageWidth : CGFloat = conversationContainerView.frame.width
//        let targetPage :CGFloat = ( type == .ConversationList) ? 1.0 :  0.0
//        let slideToX = pageWidth * targetPage
//
//        self.view.layoutIfNeeded()
//        self.conversationContainerScrollView.setContentOffset(CGPoint(x: slideToX, y:0), animated: animated)
//    }
    
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
        if scrollView != screenContainerScrollView { return }
        /// Shrink the width of the transparent view after the scrollview has animated so if the user toggles between Conversation List and Feed the trasnsparent view does not appear
        
        /// Just reached target page, expand transparent view and readjust content offset
        if page(scrollView: screenContainerScrollView) == .Feed {
            if !isTransparentViewExpanded() { modifyTransparentViewWidth(action: .Expand, andUpdate: false) }

            let setToX = conversationContainerView.frame.width * 2.0
            self.screenContainerScrollView.setContentOffset(CGPoint(x: setToX, y:0), animated: false)
            
//            if conversationContainerScrollView.contentOffset.x == 0 { showConversationScreen(.ConversationList, animated: false) } //Reset Conversation container scroll view
        } else if page(scrollView: screenContainerScrollView) == .Transparent {
            //No need to check if transparent view is expanded since we just reached transparent view.
            
//            if conversationContainerScrollView.contentOffset.x == 0 { showConversationScreen(.ConversationList, animated: false) } //Reset Conversation container scroll view
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
        if scrollView == feedScrollView {
            adjustFeedTabBarFonts()
            return
        }
//        if scrollView != screenContainerScrollView { return }

        
        let maximumHorizontalOffset: CGFloat = scrollView.contentSize.width - scrollView.frame.width
        let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x

        let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset
        
        scrollViewDidScrollToPercentageOffset(scrollView: scrollView, horizontalPercentageOffset: percentageHorizontalOffset)
    }
    
    // this just gets the percentage offset.
    func scrollViewDidScrollToPercentageOffset(scrollView: UIScrollView, horizontalPercentageOffset: CGFloat) {
        if scrollView != screenContainerScrollView { return }

        let x = horizontalPercentageOffset
        //math
        // 0.5 % offset === alpha = 0
        // 0.7 || 0.3 % offset == alpha 1
        // 0.7 <-> 0.5 == 1 <-> 0 <-> 1 == 0.5 <-> 0.3
        
        //recalculate perfect offset in range
        
        // if x <= 0.3 || x >= 0.7 -> alpha = 1
        // if x == 0.5 alpha = 0
        // if x > 0.3 && x < 0.5
            // calculate x as % of range 0.3 ... 0.5 and set alpha as 1 ... 0
        // if x < 0.7 && x > 0.5
            // calculate x as % of 0.5 ... 0.7 and set alpha 0 ... 1
        
        let leftEdge = CGFloat(0.2)
        let rightEdge = CGFloat(0.8)
        let middle = CGFloat(0.5)
        
        if x <= leftEdge || x >= rightEdge {
            backgroundColorView.alpha = 1
            imgFeed.tintColor = .lightGray
            imgConversation.tintColor = .lightGray
        } else if x == middle {
            backgroundColorView.alpha = 0
            imgConversation.tintColor = .white
            imgFeed.tintColor = .white
        } else {
            if x > leftEdge && x < middle {
                let max = middle - leftEdge
                let scaledX = x - leftEdge
                let percentageOffset = scaledX / CGFloat(max) //max = 0.5 - 0.3
                backgroundColorView.alpha = 1 - percentageOffset // let alpha = inverted percect offset
                let newButtonColor = navButtonColorWithAlpha(offset: percentageOffset)
                imgConversation.tintColor = newButtonColor
                imgFeed.tintColor = newButtonColor
            } else if x < rightEdge && x > middle {
                let scaledX = x - middle
                let max = rightEdge - middle
                let percentageOffset = scaledX / CGFloat(max) // max = 0.7 - 0.5
                backgroundColorView.alpha = percentageOffset
                let newButtonColor = navButtonColorWithAlpha(offset: 1 - percentageOffset)
                imgConversation.tintColor = newButtonColor
                imgFeed.tintColor = newButtonColor
            }
        }
    }
    
    func modifyBackgroundColor(visible: Bool) {
        if visible {
            backgroundColorView.alpha = 1
        } else {
            backgroundColorView.alpha = 0
        }
    }
    
    
    //MARK: - Feed Screen Functions
    
    @IBAction func btnHomeClicked(_ sender: Any) {
        guard let currentPage = feedPage(scrollView: feedScrollView) else { return }
        if currentPage == .Home { return }
        
        moveToFeedScreen(screen: .Home, animated: true)
    }
    
    @IBAction func btnPublicClicked(_ sender: Any) {
        guard let currentPage = feedPage(scrollView: feedScrollView) else { return }
        if currentPage == .Public { return }
        
        moveToFeedScreen(screen: .Public, animated: true)
    }
    
    @IBAction func btnLocalClicked(_ sender: Any) {
        guard let currentPage = feedPage(scrollView: feedScrollView) else { return }
        if currentPage == .Local { return }
        
        moveToFeedScreen(screen: .Local, animated: true)
    }
    
    
    private func feedPage (scrollView: UIScrollView) -> FeedScreenType? {
        let width = scrollView.frame.width
        let pageNumber = scrollView.contentOffset.x / width

        if pageNumber == 0 { return .Home }
        else if pageNumber == 1 { return .Public }
        else if pageNumber == 2 { return .Local }
        else {
            return nil
        }
    }
    
    private func moveToFeedScreen (screen: FeedScreenType, animated: Bool) {
        let pageWidth : CGFloat = feedTableContainer.frame.width
        var targetPage :CGFloat = 0.0
        
        switch screen {
        case .Home:
            targetPage = 0
        case .Public:
            targetPage = 1.0
        case .Local:
            targetPage = 2.0
        }
        
        let slideToX = pageWidth * targetPage
        
        self.view.layoutIfNeeded()
        self.feedScrollView.setContentOffset(CGPoint(x: slideToX, y:0), animated: true)
    }
    
    func adjustFeedTabBarFonts() {
        //set feed tab bar title bold
        guard let currentPage = feedPage(scrollView: feedScrollView) else { return }
        
        let bold = UIFont.boldSystemFont(ofSize: 17.0)
        let regular = UIFont.systemFont(ofSize: 17.0)
        
        if currentPage == .Home {
            self.lblHome.font = bold
            self.lblPublic.font = regular
            self.lblLocal.font = regular
        } else if currentPage == .Public {
            self.lblHome.font = regular
            self.lblPublic.font = bold
            self.lblLocal.font = regular
        } else if currentPage == .Local {
            self.lblHome.font = regular
            self.lblPublic.font = regular
            self.lblLocal.font = bold
        }
    }
    
    func navButtonColorWithAlpha(offset: CGFloat) -> UIColor {
        
        //0.68 = gray
        // 1.0 = white
        
        let gray = 0.6
        let white = 1.0
        
        let difference = white - gray
        
        //when offset is 0 it will be white, when offset is 1 it will be gray
        
        let curValue = difference*Double(offset)
        
        let newValue = gray + curValue
        let colorNum = CGFloat(newValue)
        if colorNum > 0.9 {
            return .white
        }
        
        return UIColor(red:colorNum, green:colorNum, blue:colorNum, alpha:1.0)
    }
    
}
