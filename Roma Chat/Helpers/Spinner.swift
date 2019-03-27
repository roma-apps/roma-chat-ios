//
//  Spinner.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-03-26.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import Foundation
import UIKit

enum Show {
    case show
    case hide
}

class Spinner {
    
    static let shared = Spinner()
    
    lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .whiteLarge)
        return spinner
    }()
    
    lazy var spinnerView: UIView = {
        let spinnerView = UIView(frame: UIScreen.main.bounds)
        spinnerView.backgroundColor = StoreStruct.colorSpinnerBackground
        spinnerView.addSubview(spinner)
        return spinnerView
    }()
    
    func showSpinner(show: Show) {
        DispatchQueue.main.async {
            switch show {
            case .show:
                self.spinnerView.frame = UIScreen.main.bounds
                self.spinner.center = self.spinnerView.center
                if UIApplication.shared.keyWindow?.subviews.contains(self.spinnerView) == false {
                    UIApplication.shared.keyWindow?.addSubview(self.spinnerView)
                    self.spinner.startAnimating()
                }
            case .hide:
                self.spinnerView.removeFromSuperview()
            }
        }
    }
}
