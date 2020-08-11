//
//  PathElement.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/11/20.
//

import UIKit

protocol PathElement {
    var identifier: String { get }
    var width: CGFloat { get set }
    var startPoint: CGPoint { get }
    var endPoint: CGPoint { get }
    var bounds: CGRect { get }

    var borderPath: UIBezierPath { get }

    var nextElement: PathElement? { get set }
    var previousElement: PathElement? { get set }

    var followsMoveTo: Bool { get }
    var isUpdated: Bool { get set }
    /// Used by renderers to determine when a stroke was last updated
    var version: UInt { get set }

    var events: [TouchStreamEvent] { get set }

    func clearPathCaches()
}

extension PathElement {
    var isPrediction: Bool {
        return events.first?.isPrediction ?? false
    }

    mutating func configure(previousElement: inout PathElement) {
        self.previousElement = previousElement
        previousElement.nextElement = self
    }

    mutating func updateWith(event: TouchStreamEvent, width: CGFloat) {
        if events.first?.expectsForceUpdate ?? false {
            self.width = width
        }
        clearPathCaches()
        nextElement?.clearPathCaches()

        isUpdated = true
    }
}
