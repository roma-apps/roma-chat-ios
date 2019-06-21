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
    
    @IBOutlet weak var imgView: UIImageView!
    
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
        
        self.imgView.image = image
        self.view.layoutIfNeeded()
    }
    
    func refreshImageView() {
        guard let image = self.image else { return }
        
        DispatchQueue.main.async {
            self.imgView.image = image
            self.view.layoutIfNeeded()
        }
    }
    
    
    @IBAction func btnClosePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
