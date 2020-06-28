//
//  DrawModel.swift
//  DrawUI
//
//  Created by Adam Wulf on 6/28/20.
//

import Foundation

public class DrawModel: NSCopying {

    public private(set) var touchStream: TouchStream

    required public init() {
        touchStream = TouchStream()
    }

    public func processTouchStream(with tool: Pen) {

    }
}

// MARK: - NSCopying
extension DrawModel {
    public func copy(with zone: NSZone? = nil) -> Any {
        let ret = DrawModel()

        return ret
    }
}
