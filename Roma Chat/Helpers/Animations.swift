//
//  Animations.swift
//  Roma Chat
//
//  Created by Monica Brinkman on 2019-05-02.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import UIKit

struct Animations {
    static func yRotation(_ angle: Double) -> CATransform3D {
        return CATransform3DMakeRotation(CGFloat(angle), 0.0, 1.0, 0.0)
    }
    
    static func perspectiveTransform(for containerView: UIView) {
        var transform = CATransform3DIdentity
        transform.m34 = -0.002
        containerView.layer.sublayerTransform = transform
    }
}

