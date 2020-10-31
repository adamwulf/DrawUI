//
//  SmootherTests.swift
//  DrawUITests
//
//  Created by Adam Wulf on 10/31/20.
//

import XCTest
import DrawUI

class SmootherTests: XCTestCase {
    typealias Event = TouchEvent.Simple

    func testTwoPoints() throws {
        let touchId: UITouchIdentifier = UUID().uuidString
        let completeEvents = [Event(id: touchId, loc: CGPoint(x: 100, y: 100), pred: false, update: EstimationUpdateIndex(1)),
                              Event(id: touchId, loc: CGPoint(x: 200, y: 100), pred: true),
                              Event(id: touchId, loc: CGPoint(x: 300, y: 100), pred: true),
                              Event(id: touchId, loc: CGPoint(x: 110, y: 120), pred: false, update: EstimationUpdateIndex(1)),
                              Event(id: touchId, loc: CGPoint(x: 200, y: 100), pred: false, update: EstimationUpdateIndex(2)),
                              Event(id: touchId, loc: CGPoint(x: 220, y: 120), pred: false, update: EstimationUpdateIndex(2))]
        let events = TouchEvent.newFrom(completeEvents)

        let touchStream = TouchPathStream()
        let polylineStream = PolylineStream()

        let touchOutput = touchStream.process(touchEvents: events)
        let polylineOutput = polylineStream.process(input: touchOutput)

        XCTAssertEqual(polylineOutput.lines.count, 1)
        XCTAssertEqual(polylineOutput.lines[0].points.count, 2)
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 0), IndexSet([0]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 1), IndexSet([0]))
    }
}
