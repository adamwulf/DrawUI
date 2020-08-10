//
//  DrawModel.swift
//  DrawUI
//
//  Created by Adam Wulf on 6/28/20.
//

import Foundation

public class DrawModel: NSObject, NSSecureCoding {

    // MARK: - Init

    private var version: Int
    private var strokes: [Any] // TODO: make generic for Stroke
    public private(set) var touchStream: TouchStream

    required public override init() {
        version = 0
        strokes = []
        touchStream = TouchStream()
    }

    public func processTouchStream(with tool: Pen) {
        // TODO: implement processTouchStream()
    }

    // MARK: - NSSecureCoding

    public private(set) static var supportsSecureCoding: Bool = true
    public func encode(with coder: NSCoder) {
        coder.encode(version, forKey: "version")
        coder.encode(strokes, forKey: "strokes")
    }

    required public init?(coder: NSCoder) {
        version = coder.decodeInteger(forKey: "version")
        // TODO: implement `strokes` and static type properly
        strokes = coder.decodeObject(of: [NSArray.self, NSObject.self], forKey: "strokes") as? [NSObject] ?? []
        touchStream = TouchStream()
    }
}

// MARK: - NSCopying
extension DrawModel: NSCopying {
    public func copy(with zone: NSZone? = nil) -> Any {
        let ret = DrawModel()

        return ret
    }
}
