//
//  PolylineTests.swift
//  DrawUITests
//
//  Created by Adam Wulf on 10/31/20.
//

import XCTest
import DrawUI

class PolylineTests: XCTestCase {
    typealias Event = TouchEvent.Simple

    func testCompletePolyline() throws {
        let touchId: UITouchIdentifier = UUID().uuidString
        let completeEvents = [Event(id: touchId, loc: CGPoint(x: 100, y: 100), pred: false, update: EstimationUpdateIndex(1)),
                              Event(id: touchId, loc: CGPoint(x: 200, y: 100), pred: true),
                              Event(id: touchId, loc: CGPoint(x: 110, y: 120), pred: false, update: EstimationUpdateIndex(1)),
                              Event(id: touchId, loc: CGPoint(x: 200, y: 100), pred: false, update: EstimationUpdateIndex(2)),
                              Event(id: touchId, loc: CGPoint(x: 220, y: 120), pred: false, update: EstimationUpdateIndex(2))]
        let events = TouchEvent.newFrom(completeEvents)

        var touchOutput: TouchPathStream.Produces = (paths: [], deltas: [])
        var polylineOutput: PolylineStream.Produces = (lines: [], deltas: [])
        let touchStream = TouchPathStream()
        let polylineStream = PolylineStream()
        touchStream.addConsumer(polylineStream)
        touchStream.addConsumer { (input) -> Void in
            touchOutput = input
        }
        polylineStream.addConsumer { (input) -> Void in
            polylineOutput = input
        }
        touchStream.process(events)

        XCTAssertEqual(polylineOutput.lines.count, 1)
        XCTAssertEqual(touchOutput.paths.count, polylineOutput.lines.count)
        XCTAssertEqual(polylineOutput.deltas.count, 2)
        XCTAssertEqual(touchOutput.deltas.count, polylineOutput.deltas.count)

        XCTAssertEqual(polylineOutput.lines[0].points[0].location, CGPoint(x: 110, y: 120))
        XCTAssertEqual(polylineOutput.lines[0].points[1].location, CGPoint(x: 220, y: 120))
        XCTAssertTrue(polylineOutput.lines[0].isComplete)

        XCTAssertEqual(polylineOutput.deltas[0], .addedPolyline(index: 0))
        XCTAssertEqual(polylineOutput.deltas[1], .completedPolyline(index: 0))
    }

    func testUpdatedPolyline() throws {
        let touchId: UITouchIdentifier = UUID().uuidString
        let completeEvents = [Event(id: touchId, loc: CGPoint(x: 100, y: 100), pred: false, update: EstimationUpdateIndex(1)),
                              Event(id: touchId, loc: CGPoint(x: 200, y: 100), pred: true),
                              Event(id: touchId, loc: CGPoint(x: 110, y: 120), pred: false, update: EstimationUpdateIndex(1)),
                              Event(id: touchId, loc: CGPoint(x: 200, y: 100), pred: false, update: EstimationUpdateIndex(2)),
                              Event(id: touchId, loc: CGPoint(x: 220, y: 120), pred: false, update: EstimationUpdateIndex(2))]
        let events = TouchEvent.newFrom(completeEvents)

        var touchOutput: TouchPathStream.Produces = (paths: [], deltas: [])
        var polylineOutput: PolylineStream.Produces = (lines: [], deltas: [])
        let touchStream = TouchPathStream()
        let polylineStream = PolylineStream()
        touchStream.addConsumer(polylineStream)
        touchStream.addConsumer { (input) -> Void in
            touchOutput = input
        }
        polylineStream.addConsumer { (input) -> Void in
            polylineOutput = input
        }
        touchStream.process(Array(events[0...1]))

        XCTAssertEqual(polylineOutput.lines.count, 1)
        XCTAssertEqual(touchOutput.paths.count, polylineOutput.lines.count)
        XCTAssertEqual(polylineOutput.deltas.count, 1)
        XCTAssertEqual(touchOutput.deltas.count, polylineOutput.deltas.count)

        XCTAssertEqual(polylineOutput.lines[0].points[0].location, CGPoint(x: 100, y: 100))
        XCTAssertEqual(polylineOutput.lines[0].points[1].location, CGPoint(x: 200, y: 100))
        XCTAssertFalse(polylineOutput.lines[0].isComplete)

        XCTAssertEqual(polylineOutput.deltas[0], .addedPolyline(index: 0))

        touchStream.process(Array(events[2...]))

        XCTAssertEqual(polylineOutput.lines.count, 1)
        XCTAssertEqual(touchOutput.paths.count, polylineOutput.lines.count)
        XCTAssertEqual(polylineOutput.deltas.count, 2)
        XCTAssertEqual(touchOutput.deltas.count, polylineOutput.deltas.count)

        XCTAssertEqual(polylineOutput.lines[0].points[0].location, CGPoint(x: 110, y: 120))
        XCTAssertEqual(polylineOutput.lines[0].points[1].location, CGPoint(x: 220, y: 120))
        XCTAssertTrue(polylineOutput.lines[0].isComplete)

        XCTAssertEqual(polylineOutput.deltas[0], .updatedPolyline(index: 0, updatedIndexes: IndexSet([0, 1])))
        XCTAssertEqual(polylineOutput.deltas[1], .completedPolyline(index: 0))
    }

    func testTooManyPredictionsPolyline() throws {
        let touchId: UITouchIdentifier = UUID().uuidString
        let completeEvents = [Event(id: touchId, loc: CGPoint(x: 100, y: 100), pred: false, update: EstimationUpdateIndex(1)),
                              Event(id: touchId, loc: CGPoint(x: 200, y: 100), pred: true),
                              Event(id: touchId, loc: CGPoint(x: 300, y: 100), pred: true),
                              Event(id: touchId, loc: CGPoint(x: 110, y: 120), pred: false, update: EstimationUpdateIndex(1)),
                              Event(id: touchId, loc: CGPoint(x: 200, y: 100), pred: false, update: EstimationUpdateIndex(2)),
                              Event(id: touchId, loc: CGPoint(x: 220, y: 120), pred: false, update: EstimationUpdateIndex(2))]
        let events = TouchEvent.newFrom(completeEvents)

        var touchOutput: TouchPathStream.Produces = (paths: [], deltas: [])
        var polylineOutput: PolylineStream.Produces = (lines: [], deltas: [])
        let touchStream = TouchPathStream()
        let polylineStream = PolylineStream()
        touchStream.addConsumer(polylineStream)
        touchStream.addConsumer { (input) -> Void in
            touchOutput = input
        }
        polylineStream.addConsumer { (input) -> Void in
            polylineOutput = input
        }
        touchStream.process(Array(events[0...2]))

        XCTAssertEqual(polylineOutput.lines.count, 1)
        XCTAssertEqual(touchOutput.paths.count, polylineOutput.lines.count)
        XCTAssertEqual(polylineOutput.deltas.count, 1)
        XCTAssertEqual(touchOutput.deltas.count, polylineOutput.deltas.count)

        XCTAssertEqual(polylineOutput.lines[0].points.count, 3)
        XCTAssertEqual(polylineOutput.lines[0].points[0].location, CGPoint(x: 100, y: 100))
        XCTAssertEqual(polylineOutput.lines[0].points[1].location, CGPoint(x: 200, y: 100))
        XCTAssertEqual(polylineOutput.lines[0].points[2].location, CGPoint(x: 300, y: 100))
        XCTAssertFalse(polylineOutput.lines[0].isComplete)

        XCTAssertEqual(polylineOutput.deltas[0], .addedPolyline(index: 0))

        touchStream.process(Array(events[3...]))

        XCTAssertEqual(polylineOutput.lines.count, 1)
        XCTAssertEqual(touchOutput.paths.count, polylineOutput.lines.count)
        XCTAssertEqual(polylineOutput.deltas.count, 2)
        XCTAssertEqual(touchOutput.deltas.count, polylineOutput.deltas.count)

        // predicted point was removed
        XCTAssertEqual(polylineOutput.lines[0].points.count, 2)
        XCTAssertEqual(polylineOutput.lines[0].points[0].location, CGPoint(x: 110, y: 120))
        XCTAssertEqual(polylineOutput.lines[0].points[1].location, CGPoint(x: 220, y: 120))
        XCTAssertTrue(polylineOutput.lines[0].isComplete)

        XCTAssertEqual(polylineOutput.deltas[0], .updatedPolyline(index: 0, updatedIndexes: IndexSet([0, 1, 2])))
        XCTAssertEqual(polylineOutput.deltas[1], .completedPolyline(index: 0))
    }
}
