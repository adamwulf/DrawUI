//
//  BezierStreamTests.swift
//  DrawUITests
//
//  Created by Adam Wulf on 4/8/21.
//

import XCTest
import DrawUI
import MMSwiftToolbox

typealias Event = TouchEvent.Simple

extension Polyline {

    init(from start: Event, to end: Event, step: CGFloat = 10) {
        guard step > 0 else {
            self.init(points: Polyline.Point.newFrom([start, end]))
            return
        }

        let dist = start.loc.distance(to: end.loc)
        let vec = (end.loc - start.loc).normalize(to: step)

        var events = [start]
        var previous = start.loc
        for _ in 0 ..< Int(dist / step) {
            let next = previous + vec
            events.append(Event(loc: next))
            previous = next
        }
        if let last = events.last?.loc,
           end.loc != last {
            events.append(end)
        }

        self.init(points: Polyline.Point.newFrom(events))
    }

    // Assert that the defined points along the Polyline align exactly with
    // the element endpoints along the Bezier path.
    static func == (lhs: Polyline, rhs: UIBezierPath) -> Bool {
        guard lhs.points.count == rhs.elementCount else { XCTFail(); return false }
        for (i, point) in lhs.points.enumerated() {
            guard point.location == rhs.pointOnPath(atElement: i, andTValue: 1) else {
                XCTFail()
                return false
            }
        }
        return true
    }
}

class BezierStreamTests: XCTestCase {
    static let pen = AttributesStream.ToolStyle(width: 10, color: .black)
    static let eraser = AttributesStream.ToolStyle(width: 10, color: nil)

    func testSimpleBezierPath() throws {
        let completeEvents = [Event(x: 100, y: 100),
                              Event(x: 110, y: 110),
                              Event(x: 120, y: 160),
                              Event(x: 130, y: 120),
                              Event(x: 140, y: 120),
                              Event(x: 150, y: 110)]
        let points = Polyline.Point.newFrom(completeEvents)
        let line = Polyline(points: points)
        let polylineOutput = PolylineStream.Produces(lines: [line], deltas: [.addedPolyline(index: 0)])

        let attributeStream = AttributesStream()
        attributeStream.styleOverride = { delta in
            switch delta {
            case .addedBezierPath(let index):
                return index == 0 ? Self.pen : Self.eraser
            default:
                return nil
            }
        }
        let bezierStream = BezierStream(smoother: AntigrainSmoother())
        let attributedOutput = attributeStream.produce(with: bezierStream.produce(with: polylineOutput))

        XCTAssert(polylineOutput.lines[0] == attributedOutput.paths[0])
        XCTAssert(attributedOutput.paths[0].color == .black)
        XCTAssertEqual(attributedOutput.deltas[0], .addedBezierPath(index: 0))
    }
}
