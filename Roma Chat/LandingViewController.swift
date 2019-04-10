//
//  ViewController.swift
//  Roma Chat
//
//  Created by Barrett Breshears on 3/8/19.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var txtServerUrl: UITextField!
    @IBOutlet weak var btnGo: UIButton!
    
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
        txtServerUrl.text = ""
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
        if let url = txtServerUrl.text, !url.isEmpty {
            AuthenticationManager.shared.authenticate(url) { safariVC, error in
                if let error = error {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
                    }
                    return
                }
                guard let safariVC = safariVC else { return }
                UIApplication.shared.keyWindow?.rootViewController?.present(safariVC, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "Please enter a server url.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
          
        }

    }
    
}

