//
//  ConversationListViewController.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-03-20.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import UIKit

class ConversationListViewController: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    
    //MARK: - UITableViewDelegate & UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 25
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationListCell") as! ConversationListCell

        return cell
    }
    
}
