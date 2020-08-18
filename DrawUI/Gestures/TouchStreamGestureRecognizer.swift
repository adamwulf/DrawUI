//
//  TouchStreamGestureRecognizer.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/16/20.
//

import UIKit

public class TouchStreamGestureRecognizer: UIGestureRecognizer, UIGestureRecognizerDelegate {

    weak var touchStream: TouchEventStream?
    var activeTouches: Set<UITouch>

    public init(touchStream: TouchEventStream, target: Any?, action: Selector?) {
        self.touchStream = touchStream
        self.activeTouches = Set()

        super.init(target: target, action: action)

        delaysTouchesBegan = false
        delaysTouchesEnded = false
        allowedTouchTypes = [NSNumber(value: UITouch.TouchType.direct.rawValue), NSNumber(value: UITouch.TouchType.stylus.rawValue)]
        delegate = self
    }

    public override func canBePrevented(by preventingGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    public override func shouldBeRequiredToFail(by otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    func process(touches: Set<UITouch>, with event: UIEvent?, isUpdate: Bool) {
        for touch in touches {
            var coalesced = event?.coalescedTouches(for: touch) ?? [touch]

            if coalesced.isEmpty {
                coalesced = [touch]
            }

            for coalescedTouch in coalesced {
                touchStream?.add(event: TouchEvent(coalescedTouch: coalescedTouch, touch: touch, isUpdate: isUpdate, isPrediction: false))
            }

            let predicted = event?.predictedTouches(for: touch) ?? []

            for predictedTouch in predicted {
                touchStream?.add(event: TouchEvent(coalescedTouch: predictedTouch, touch: touch, isUpdate: isUpdate, isPrediction: true))
            }
        }
    }

    public override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        process(touches: touches, with: nil, isUpdate: true)
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        activeTouches.formUnion(touches)

        super.touchesBegan(touches, with: event)
        process(touches: touches, with: event, isUpdate: false)
        state = .began
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        process(touches: touches, with: event, isUpdate: false)
        state = .changed
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        activeTouches.subtract(touches)

        super.touchesEnded(touches, with: event)
        process(touches: touches, with: event, isUpdate: false)

        if activeTouches.isEmpty {
            state = .ended
        } else {
            state = .changed
        }
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        activeTouches.subtract(touches)

        super.touchesCancelled(touches, with: event)
        process(touches: touches, with: event, isUpdate: false)

        if activeTouches.isEmpty {
            state = .ended
        } else {
            state = .changed
        }
    }
}

// MARK: - UIGestureRecognizer (Delegate)

extension TouchStreamGestureRecognizer {
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
