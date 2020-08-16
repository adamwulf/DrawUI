//
//  DebugView.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 8/16/20.
//

import UIKit
import DrawUI

class DebugView: UIView {
    var lastSeenEvent: TouchStreamEvent?
    var touchStream: TouchStream?

    override init(frame: CGRect) {
        super.init(frame: frame)
        clearsContextBeforeDrawing = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func draw(_ rect: CGRect) {
        let updatedEvents = touchStream?.eventsSince(event: lastSeenEvent)

        for event in updatedEvents ?? [] {
            if event.isUpdate {
                UIColor.green.setFill()
            } else if event.isPrediction {
                UIColor.blue.setFill()
            } else {
                UIColor.red.setFill()
            }
            UIBezierPath(ovalIn: CGRect(origin: event.location, size: CGSize.zero).insetBy(dx: -2, dy: -2)).fill()
        }
    }
}
