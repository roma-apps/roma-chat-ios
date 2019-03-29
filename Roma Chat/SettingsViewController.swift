//
//  SettingsViewController.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-03-28.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import UIKit

struct TitleDetail {
    var title: String?
    var detail: String?
}

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tblSettings: UITableView!
    
    let titles: [TitleDetail] = [TitleDetail(title: "Logout", detail: nil)]
    let numSections = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblSettings.register(UINib(nibName: Storyboard.settingsTableViewCell, bundle: nil), forCellReuseIdentifier: Storyboard.settingsTableViewCell)
    }
    
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - UITableView
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.settingsTableViewCell)! as? SettingsTableViewCell else { return UITableViewCell() }
    
        let item = titles[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.detail
        cell.accessoryType = .disclosureIndicator
        
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: //Logout
            showLogoutAlert()
        default:
            return
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    //TODO: Use custom headers
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "ACCOUNT ACTIONS"
        default:
            return ""
        }
    }
    
    private func showLogoutAlert() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you wish to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            ///Logout
            AuthenticationManager.shared.logout()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    
}
