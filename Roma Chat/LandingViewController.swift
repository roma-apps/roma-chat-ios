//
//  ViewController.swift
//  Roma Chat
//
//  Created by Barrett Breshears on 3/8/19.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var txtServerUrl: UITextField!
    @IBOutlet weak var btnGo: UIButton!
    
    @IBOutlet weak var urlPickerView: UIPickerView!
    
    let urls: [String] = ["mastodon.social", "social.im", "myfreecams.com"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let scrollViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        scrollView.addGestureRecognizer(scrollViewTapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        txtServerUrl.text = urls[0]
    }

    //TODO: Fix up scrolling only when overlapping views
    @objc func keyboardWillShow(notification: NSNotification) {
        print("keyboardWillShow")
        
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardHeight = keyboardSize.height
        
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.scrollRectToVisible(btnGo.frame, animated: true)
    }

    @objc func keyboardWillHide(notification: NSNotification){
        print("keyboardWillHide")
        self.scrollView.contentInset = UIEdgeInsets.zero;
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        txtServerUrl.resignFirstResponder()
    }
    
    @IBAction func btnGoPressed(_ sender: UIButton) {
        guard let url = txtServerUrl.text else { return }
        AuthenticationManager.shared.authenticate(url) { safariVC in
            self.navigationController?.present(safariVC, animated: true, completion: nil)
            
//            guard let masterViewController = self.storyboard?.instantiateViewController(withIdentifier: "MasterViewController") else { return }
//            self.navigationController?.pushViewController(masterViewController, animated: true)
        }
    }
    
    
    //MARK: - Picker View
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return urls.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return urls[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        txtServerUrl.text = urls[row]
    }

}

