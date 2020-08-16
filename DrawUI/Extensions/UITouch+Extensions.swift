//
//  UITouch+Extensions.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/10/20.
//

import UIKit
import ObjectiveC

private var TOUCH_IDENTIFIER: UInt8 = 0

extension UITouch {
    var identifer: String {
        if let identifier = objc_getAssociatedObject(self, &TOUCH_IDENTIFIER) as? String {
            return identifier
        } else {
            let identifier = UUID().uuidString
            objc_setAssociatedObject(self, &TOUCH_IDENTIFIER, identifier, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return identifier
        }
    }
}
