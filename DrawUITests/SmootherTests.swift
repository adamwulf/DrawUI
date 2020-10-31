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

    func testThreePoints() throws {
        let touchId: UITouchIdentifier = UUID().uuidString
        let completeEvents = [Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100))]
        let events = TouchEvent.newFrom(completeEvents)

        let touchStream = TouchPathStream()
        let polylineStream = PolylineStream()

        let touchOutput = touchStream.process(touchEvents: events)
        let polylineOutput = polylineStream.process(input: touchOutput)

        XCTAssertEqual(polylineOutput.lines.count, 1)
        XCTAssertEqual(polylineOutput.lines[0].points.count, 3)
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 0), IndexSet([0, 1]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 1), IndexSet([0, 1]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 2), IndexSet([1]))
    }

    func testFourPoints() throws {
        let touchId: UITouchIdentifier = UUID().uuidString
        let completeEvents = [Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100))]
        let events = TouchEvent.newFrom(completeEvents)

        let touchStream = TouchPathStream()
        let polylineStream = PolylineStream()

        let touchOutput = touchStream.process(touchEvents: events)
        let polylineOutput = polylineStream.process(input: touchOutput)

        XCTAssertEqual(polylineOutput.lines.count, 1)
        XCTAssertEqual(polylineOutput.lines[0].points.count, 4)
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 0), IndexSet([0, 1]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 1), IndexSet([0, 1]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 2), IndexSet([1]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 3), IndexSet([1]))
    }

    func testFivePoints() throws {
        let touchId: UITouchIdentifier = UUID().uuidString
        let completeEvents = [Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100))]
        let events = TouchEvent.newFrom(completeEvents)

        let touchStream = TouchPathStream()
        let polylineStream = PolylineStream()

        let touchOutput = touchStream.process(touchEvents: events)
        let polylineOutput = polylineStream.process(input: touchOutput)

        XCTAssertEqual(polylineOutput.lines.count, 1)
        XCTAssertEqual(polylineOutput.lines[0].points.count, 5)
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 0), IndexSet([0, 1]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 1), IndexSet([0, 1, 2]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 2), IndexSet([1, 2]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 3), IndexSet([1, 2]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 4), IndexSet([2]))
    }

    func testSixPoints() throws {
        let touchId: UITouchIdentifier = UUID().uuidString
        let completeEvents = [Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100))]
        let events = TouchEvent.newFrom(completeEvents)

        let touchStream = TouchPathStream()
        let polylineStream = PolylineStream()

        let touchOutput = touchStream.process(touchEvents: events)
        let polylineOutput = polylineStream.process(input: touchOutput)

        XCTAssertEqual(polylineOutput.lines.count, 1)
        XCTAssertEqual(polylineOutput.lines[0].points.count, 6)
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 0), IndexSet([0, 1]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 1), IndexSet([0, 1, 2]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 2), IndexSet([1, 2, 3]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 3), IndexSet([1, 2, 3]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 4), IndexSet([2, 3]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 5), IndexSet([3]))
    }

    func testSevenPoints() throws {
        let touchId: UITouchIdentifier = UUID().uuidString
        let completeEvents = [Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100))]
        let events = TouchEvent.newFrom(completeEvents)

        let touchStream = TouchPathStream()
        let polylineStream = PolylineStream()

        let touchOutput = touchStream.process(touchEvents: events)
        let polylineOutput = polylineStream.process(input: touchOutput)

        XCTAssertEqual(polylineOutput.lines.count, 1)
        XCTAssertEqual(polylineOutput.lines[0].points.count, 7)
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 0), IndexSet([0, 1]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 1), IndexSet([0, 1, 2]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 2), IndexSet([1, 2, 3]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 3), IndexSet([1, 2, 3, 4]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 4), IndexSet([2, 3, 4]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 5), IndexSet([3, 4]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 6), IndexSet([4]))
    }

    func testEightPoints() throws {
        let touchId: UITouchIdentifier = UUID().uuidString
        let completeEvents = [Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100))]
        let events = TouchEvent.newFrom(completeEvents)

        let touchStream = TouchPathStream()
        let polylineStream = PolylineStream()

        let touchOutput = touchStream.process(touchEvents: events)
        let polylineOutput = polylineStream.process(input: touchOutput)

        XCTAssertEqual(polylineOutput.lines.count, 1)
        XCTAssertEqual(polylineOutput.lines[0].points.count, 8)
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 0), IndexSet([0, 1]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 1), IndexSet([0, 1, 2]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 2), IndexSet([1, 2, 3]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 3), IndexSet([1, 2, 3, 4]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 4), IndexSet([2, 3, 4, 5]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 5), IndexSet([3, 4, 5]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 6), IndexSet([4, 5]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0], index: 7), IndexSet([5]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0],
                                                            indexes: IndexSet([0, 7])), IndexSet([0, 1, 5]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0],
                                                            indexes: IndexSet([6, 7])), IndexSet([4, 5]))
        XCTAssertEqual(AntigrainSmoother.smoothedIndexesFor(polyline: polylineOutput.lines[0],
                                                            indexes: IndexSet([3, 4])), IndexSet([1, 2, 3, 4, 5]))
    }
}
