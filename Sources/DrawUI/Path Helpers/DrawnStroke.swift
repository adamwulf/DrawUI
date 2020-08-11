//
//  DrawnStroke.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/10/20.
//

import UIKit
import CoreGraphics

class DrawnStroke {

    let identifier: String
    var path: UIBezierPath?
    var borderPath: UIBezierPath?
    private(set) var segments: [PathElement]
    private var eventIdToSegment: [String: PathElement]
    private var waitingEvents: [TouchStreamEvent]
    let tool: Pen

    /// The first event that created this stroke. the [event touchIdentifier] can be useful for mapping this stroke to a [UITouch identifier]
    private(set) var event: TouchStreamEvent?

    /// Used by renderers to determine when a stroke was last updated
    let version: UInt

    private let smoother: SegmentSmoother
    private let savedSmoother: SegmentSmoother

    init(with tool: Pen) {
        identifier = UUID().uuidString
        self.tool = tool
        segments = []
        smoother = SegmentSmoother()
        savedSmoother = smoother
        eventIdToSegment = [:]
        waitingEvents = []
        version = 0
        event = nil
    }
}
