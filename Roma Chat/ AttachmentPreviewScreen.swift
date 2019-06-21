//
//   AttachmentPreviewScreen.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-06-21.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import UIKit

class AttachmentPreviewScreen: UIViewController {
    
    var attachment: Attachment?
    
    var image: UIImage?
    
    @IBOutlet weak var imgClose: UIImageView!
    
    @IBOutlet weak var attachmentContainer: UIView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var zoomableScrollView: ImageZoomView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgClose.image = UIImage(named: "X")!.withRenderingMode(.alwaysTemplate)
        imgClose.tintColor = .white
        
        guard let attachment = attachment else { return }
        
        ApiManager.shared.fetchImageForAttachment(attachment: attachment) { [weak self] (image) in
            self?.image = image
            self?.refreshImageView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let image = self.image else {return}
        
        zoomableScrollView = ImageZoomView(frame: attachmentContainer.frame, image: image)
        self.attachmentContainer.addSubview(self.zoomableScrollView!)
        self.zoomableScrollView!.translatesAutoresizingMaskIntoConstraints = false
        
        self.attachmentContainer.addConstraint(NSLayoutConstraint(item: self.zoomableScrollView!, attribute: .trailing, relatedBy: .equal, toItem: self.attachmentContainer, attribute: .trailing, multiplier: 1, constant: 0))
        self.attachmentContainer.addConstraint(NSLayoutConstraint(item: self.zoomableScrollView!, attribute: .leading, relatedBy: .equal, toItem: self.attachmentContainer, attribute: .leading, multiplier: 1, constant: 0))
        
        self.attachmentContainer.addConstraint(NSLayoutConstraint(item: self.zoomableScrollView!, attribute: .top, relatedBy: .equal, toItem: self.attachmentContainer, attribute: .top, multiplier: 1, constant: 0))
        self.attachmentContainer.addConstraint(NSLayoutConstraint(item: self.zoomableScrollView!, attribute: .bottom, relatedBy: .equal, toItem: self.attachmentContainer, attribute: .bottom, multiplier: 1, constant: 0))
        
        self.spinner.stopAnimating()
        
//        self.imgView.image = image
//        self.view.layoutIfNeeded()
    }
    
    func refreshImageView() {
        guard let image = self.image else { return }
        
        DispatchQueue.main.async {
            if let scrollView = self.zoomableScrollView {
                scrollView.imageView.image = image
                scrollView.layoutIfNeeded()
            } else {
                self.zoomableScrollView = ImageZoomView(frame: self.attachmentContainer.frame, image: image)
                self.attachmentContainer.addSubview(self.zoomableScrollView!)
                self.zoomableScrollView!.translatesAutoresizingMaskIntoConstraints = false
                
                self.attachmentContainer.addConstraint(NSLayoutConstraint(item: self.zoomableScrollView!, attribute: .trailing, relatedBy: .equal, toItem: self.attachmentContainer, attribute: .trailing, multiplier: 1, constant: 0))
                self.attachmentContainer.addConstraint(NSLayoutConstraint(item: self.zoomableScrollView!, attribute: .leading, relatedBy: .equal, toItem: self.attachmentContainer, attribute: .leading, multiplier: 1, constant: 0))
                
                self.attachmentContainer.addConstraint(NSLayoutConstraint(item: self.zoomableScrollView!, attribute: .top, relatedBy: .equal, toItem: self.attachmentContainer, attribute: .top, multiplier: 1, constant: 0))
                self.attachmentContainer.addConstraint(NSLayoutConstraint(item: self.zoomableScrollView!, attribute: .bottom, relatedBy: .equal, toItem: self.attachmentContainer, attribute: .bottom, multiplier: 1, constant: 0))
                
                self.spinner.stopAnimating()

            }
        }
    }
    
    
    @IBAction func btnClosePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
