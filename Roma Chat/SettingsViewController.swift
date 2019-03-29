//
//  SettingsViewController.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-03-28.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
