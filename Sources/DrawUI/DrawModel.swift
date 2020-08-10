//
//  DrawModel.swift
//  DrawUI
//
//  Created by Adam Wulf on 6/28/20.
//

import Foundation

public class DrawModel {

    // MARK: - Init

    private var version: Int
    private var strokes: [Any] // TODO: make generic for Stroke
    public private(set) var touchStream: TouchStream

    init() {
        version = 0
        strokes = []
        touchStream = TouchStream()
    }

    public func processTouchStream(with tool: Pen) {
        // TODO: implement processTouchStream()
    }
}

// MARK: - NSCopying
extension DrawModel: NSCopying {
    public func copy(with zone: NSZone? = nil) -> Any {
        let ret = DrawModel()

        return ret
    }
}
