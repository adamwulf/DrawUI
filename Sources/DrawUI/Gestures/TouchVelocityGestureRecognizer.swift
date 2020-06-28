//
//  File.swift
//  DrawUI
//
//  Created by Adam Wulf on 6/28/20.
//

import UIKit

public class TouchVelocityGestureRecognizer: UIGestureRecognizer, UIGestureRecognizerDelegate {

    public static var sharedInstance = TouchVelocityGestureRecognizer()

    private init() {
        super.init(target: nil, action: nil)
        delegate = self
    }

    public override func canBePrevented(by preventingGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    public override func shouldBeRequiredToFail(by otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

// MARK: - UIGestureRecognizer (Delegate)
extension TouchVelocityGestureRecognizer {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
