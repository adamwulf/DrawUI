//
//  AntigrainSmootherTests.swift
//  DrawUITests
//
//  Created by Adam Wulf on 10/31/20.
//

import XCTest
import DrawUI

class AntigrainSmootherTests: XCTestCase {
    typealias Event = TouchEvent.Simple

    func testTwoUpdatedPoints() throws {
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

        let touchOutput = touchStream.produce(with: events)
        let polylineOutput = polylineStream.produce(with: touchOutput)

        XCTAssertEqual(polylineOutput.lines.count, 1)
        XCTAssertEqual(polylineOutput.lines[0].points.count, 2)
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 0), IndexSet([0]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 1), IndexSet())
    }

    func testOnePoints() throws {
        let touchId: UITouchIdentifier = UUID().uuidString
        let completeEvents = [Event(id: touchId, loc: CGPoint(x: 100, y: 100))]
        let events = TouchEvent.newFrom(completeEvents)

        let touchStream = TouchPathStream()
        let polylineStream = PolylineStream()

        let touchOutput = touchStream.produce(with: events)
        let polylineOutput = polylineStream.produce(with: touchOutput)

        XCTAssertEqual(polylineOutput.lines.count, 1)
        XCTAssertEqual(polylineOutput.lines[0].points.count, 1)
        XCTAssertEqual(polylineOutput.lines[0].antigrainMaxIndex, 0)
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 0), IndexSet([0]))
    }

    func testTwoPoints() throws {
        let touchId: UITouchIdentifier = UUID().uuidString
        let completeEvents = [Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100))]
        let events = TouchEvent.newFrom(completeEvents)

        let touchStream = TouchPathStream()
        let polylineStream = PolylineStream()

        let touchOutput = touchStream.produce(with: events)
        let polylineOutput = polylineStream.produce(with: touchOutput)

        XCTAssertEqual(polylineOutput.lines.count, 1)
        XCTAssertEqual(polylineOutput.lines[0].points.count, 2)
        XCTAssertEqual(polylineOutput.lines[0].antigrainMaxIndex, 0)
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 0), IndexSet([0]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 1), IndexSet())
    }

    func testThreePoints() throws {
        let touchId: UITouchIdentifier = UUID().uuidString
        let completeEvents = [Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 100, y: 100))]
        let events = TouchEvent.newFrom(completeEvents)

        let touchStream = TouchPathStream()
        let polylineStream = PolylineStream()

        let touchOutput = touchStream.produce(with: events)
        let polylineOutput = polylineStream.produce(with: touchOutput)

        XCTAssertEqual(polylineOutput.lines.count, 1)
        XCTAssertEqual(polylineOutput.lines[0].points.count, 3)
        XCTAssertEqual(polylineOutput.lines[0].antigrainMaxIndex, 2)
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 0), IndexSet([0, 1, 2]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 1), IndexSet([1, 2]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 2), IndexSet([1, 2]))
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

        let touchOutput = touchStream.produce(with: events)
        let polylineOutput = polylineStream.produce(with: touchOutput)

        XCTAssertEqual(polylineOutput.lines.count, 1)
        XCTAssertEqual(polylineOutput.lines[0].points.count, 4)
        XCTAssertEqual(polylineOutput.lines[0].antigrainMaxIndex, 3)
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 0), IndexSet([0, 1, 2]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 1), IndexSet([1, 2, 3]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 2), IndexSet([1, 2, 3]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 3), IndexSet([2, 3]))
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

        let touchOutput = touchStream.produce(with: events)
        let polylineOutput = polylineStream.produce(with: touchOutput)

        XCTAssertEqual(polylineOutput.lines.count, 1)
        XCTAssertEqual(polylineOutput.lines[0].points.count, 5)
        XCTAssertEqual(polylineOutput.lines[0].antigrainMaxIndex, 4)
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 0), IndexSet([0, 1, 2]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 1), IndexSet([1, 2, 3]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 2), IndexSet([1, 2, 3, 4]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 3), IndexSet([2, 3, 4]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 4), IndexSet([3, 4]))
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

        let touchOutput = touchStream.produce(with: events)
        let polylineOutput = polylineStream.produce(with: touchOutput)

        XCTAssertEqual(polylineOutput.lines.count, 1)
        XCTAssertEqual(polylineOutput.lines[0].points.count, 6)
        XCTAssertEqual(polylineOutput.lines[0].antigrainMaxIndex, 5)
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 0), IndexSet([0, 1, 2]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 1), IndexSet([1, 2, 3]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 2), IndexSet([1, 2, 3, 4]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 3), IndexSet([2, 3, 4, 5]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 4), IndexSet([3, 4, 5]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 5), IndexSet([4, 5]))
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

        let touchOutput = touchStream.produce(with: events)
        let polylineOutput = polylineStream.produce(with: touchOutput)

        XCTAssertEqual(polylineOutput.lines.count, 1)
        XCTAssertEqual(polylineOutput.lines[0].points.count, 7)
        XCTAssertEqual(polylineOutput.lines[0].antigrainMaxIndex, 6)
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 0), IndexSet([0, 1, 2]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 1), IndexSet([1, 2, 3]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 2), IndexSet([1, 2, 3, 4]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 3), IndexSet([2, 3, 4, 5]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 4), IndexSet([3, 4, 5, 6]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 5), IndexSet([4, 5, 6]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 6), IndexSet([5, 6]))
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

        let touchOutput = touchStream.produce(with: events)
        let polylineOutput = polylineStream.produce(with: touchOutput)

        XCTAssertEqual(polylineOutput.lines[0].antigrainMaxIndex, 7)

        XCTAssertEqual(polylineOutput.lines.count, 1)
        XCTAssertEqual(polylineOutput.lines[0].points.count, 8)
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 0), IndexSet([0, 1, 2]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 1), IndexSet([1, 2, 3]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 2), IndexSet([1, 2, 3, 4]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 3), IndexSet([2, 3, 4, 5]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 4), IndexSet([3, 4, 5, 6]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 5), IndexSet([4, 5, 6, 7]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 6), IndexSet([5, 6, 7]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(index: 7), IndexSet([6, 7]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(indexes: IndexSet([0, 7])), IndexSet([0, 1, 2, 6, 7]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(indexes: IndexSet([6, 7])), IndexSet([5, 6, 7]))
        XCTAssertEqual(polylineOutput.lines[0].antigrainIndexesFor(indexes: IndexSet([3, 4])), IndexSet([2, 3, 4, 5, 6]))
    }

    func testThreePointsElement() throws {
        let touchId: UITouchIdentifier = UUID().uuidString
        let completeEvents = [Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 200, y: 150)),
                              Event(id: touchId, loc: CGPoint(x: 300, y: 150))]
        let events = TouchEvent.newFrom(completeEvents)

        let touchStream = TouchPathStream()
        let polylineStream = PolylineStream()

        let touchOutput = touchStream.produce(with: events)
        let polylineOutput = polylineStream.produce(with: touchOutput)

        let antigrain = AntigrainSmoother()

        XCTAssertEqual(polylineOutput.lines[0].antigrainMaxIndex, 2)

        var ele = antigrain.element(in: polylineOutput.lines[0], at: 0)

        XCTAssertEqual(ele, .moveTo(point: polylineOutput.lines[0].points[0]))

        ele = antigrain.element(in: polylineOutput.lines[0], at: 1)

        XCTAssertEqual(ele, .curveTo(point: polylineOutput.lines[0].points[1],
                                     ctrl1: CGPoint(x: 135.0, y: 117.5),
                                     ctrl2: CGPoint(x: 163.0495168499706, y: 140.76237921249262)))

        ele = antigrain.element(in: polylineOutput.lines[0], at: 2)

        XCTAssertEqual(ele, .curveTo(point: polylineOutput.lines[0].points[2],
                                     ctrl1: CGPoint(x: 233.0495168499706, y: 158.26237921249262),
                                     ctrl2: CGPoint(x: 265.0, y: 150.0)))
    }

    func testFourPointsElement() throws {
        let touchId: UITouchIdentifier = UUID().uuidString
        let completeEvents = [Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 200, y: 150)),
                              Event(id: touchId, loc: CGPoint(x: 300, y: 150)),
                              Event(id: touchId, loc: CGPoint(x: 400, y: 100))]
        let events = TouchEvent.newFrom(completeEvents)

        let touchStream = TouchPathStream()
        let polylineStream = PolylineStream()

        let touchOutput = touchStream.produce(with: events)
        let polylineOutput = polylineStream.produce(with: touchOutput)

        let antigrain = AntigrainSmoother()

        XCTAssertEqual(polylineOutput.lines[0].antigrainMaxIndex, 3)

        var ele = antigrain.element(in: polylineOutput.lines[0], at: 0)

        XCTAssertEqual(ele, .moveTo(point: polylineOutput.lines[0].points[0]))

        ele = antigrain.element(in: polylineOutput.lines[0], at: 1)

        XCTAssertEqual(ele, .curveTo(point: polylineOutput.lines[0].points[1],
                                     ctrl1: CGPoint(x: 135.0, y: 117.5),
                                     ctrl2: CGPoint(x: 163.0495168499706, y: 140.76237921249262)))

        ele = antigrain.element(in: polylineOutput.lines[0], at: 2)

        XCTAssertEqual(ele, .curveTo(point: polylineOutput.lines[0].points[2],
                                     ctrl1: CGPoint(x: 233.0495168499706, y: 158.26237921249262),
                                     ctrl2: CGPoint(x: 266.9504831500295, y: 158.26237921249262)))

        ele = antigrain.element(in: polylineOutput.lines[0], at: 3)

        XCTAssertEqual(ele, .curveTo(point: polylineOutput.lines[0].points[3],
                                     ctrl1: CGPoint(x: 336.9504831500294, y: 140.76237921249262),
                                     ctrl2: CGPoint(x: 365.0, y: 117.5)))
    }

    func testFivePointsElement() throws {
        let touchId: UITouchIdentifier = UUID().uuidString
        let completeEvents = [Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 200, y: 150)),
                              Event(id: touchId, loc: CGPoint(x: 300, y: 150)),
                              Event(id: touchId, loc: CGPoint(x: 400, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 500, y: 120))]
        let events = TouchEvent.newFrom(completeEvents)

        let touchStream = TouchPathStream()
        let polylineStream = PolylineStream()

        let touchOutput = touchStream.produce(with: events)
        let polylineOutput = polylineStream.produce(with: touchOutput)

        let antigrain = AntigrainSmoother()

        XCTAssertEqual(polylineOutput.lines[0].antigrainMaxIndex, 4)

        var ele = antigrain.element(in: polylineOutput.lines[0], at: 0)

        XCTAssertEqual(ele, .moveTo(point: polylineOutput.lines[0].points[0]))

        ele = antigrain.element(in: polylineOutput.lines[0], at: 1)

        XCTAssertEqual(ele, .curveTo(point: polylineOutput.lines[0].points[1],
                                     ctrl1: CGPoint(x: 135.0, y: 117.5),
                                     ctrl2: CGPoint(x: 163.0495168499706, y: 140.76237921249262)))

        ele = antigrain.element(in: polylineOutput.lines[0], at: 2)

        XCTAssertEqual(ele, .curveTo(point: polylineOutput.lines[0].points[2],
                                     ctrl1: CGPoint(x: 233.0495168499706, y: 158.26237921249262),
                                     ctrl2: CGPoint(x: 266.9504831500295, y: 158.26237921249262)))

        ele = antigrain.element(in: polylineOutput.lines[0], at: 3)

        XCTAssertEqual(ele, .curveTo(point: polylineOutput.lines[0].points[3],
                                     ctrl1: CGPoint(x: 336.9504831500294, y: 140.76237921249262),
                                     ctrl2: CGPoint(x: 363.39180836637934, y: 105.49122874504309)))

        ele = antigrain.element(in: polylineOutput.lines[0], at: 4)

        XCTAssertEqual(ele, .curveTo(point: polylineOutput.lines[0].points[4],
                                     ctrl1: CGPoint(x: 433.39180836637934, y: 94.99122874504309),
                                     ctrl2: CGPoint(x: 465, y: 113)))
    }

    func testPiecewiseFivePointsElement() throws {
        let touchId: UITouchIdentifier = UUID().uuidString
        let completeEvents = [Event(id: touchId, loc: CGPoint(x: 100, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 200, y: 150)),
                              Event(id: touchId, loc: CGPoint(x: 300, y: 150)),
                              Event(id: touchId, loc: CGPoint(x: 400, y: 100)),
                              Event(id: touchId, loc: CGPoint(x: 500, y: 120))]
        let events = TouchEvent.newFrom(completeEvents)

        let touchStream = TouchPathStream()
        let polylineStream = PolylineStream()

        var touchOutput = touchStream.produce(with: Array(events[0...3]))
        var polylineOutput = polylineStream.produce(with: touchOutput)

        let antigrain = AntigrainSmoother()

        XCTAssertEqual(polylineOutput.lines[0].antigrainMaxIndex, 2)

        var ele = antigrain.element(in: polylineOutput.lines[0], at: 0)

        XCTAssertEqual(ele, .moveTo(point: polylineOutput.lines[0].points[0]))

        ele = antigrain.element(in: polylineOutput.lines[0], at: 1)

        XCTAssertEqual(ele, .curveTo(point: polylineOutput.lines[0].points[1],
                                     ctrl1: CGPoint(x: 135.0, y: 117.5),
                                     ctrl2: CGPoint(x: 163.0495168499706, y: 140.76237921249262)))

        ele = antigrain.element(in: polylineOutput.lines[0], at: 2)

        XCTAssertEqual(ele, .curveTo(point: polylineOutput.lines[0].points[2],
                                     ctrl1: CGPoint(x: 233.0495168499706, y: 158.26237921249262),
                                     ctrl2: CGPoint(x: 266.9504831500295, y: 158.26237921249262)))

        // Now we complete the stroke, and when we complete it adds the segment that would normally be
        // smoothed from the added point, as well as the very last element so that we reach the last point

        touchOutput = touchStream.produce(with: [events[4]])
        polylineOutput = polylineStream.produce(with: touchOutput)

        XCTAssertEqual(polylineOutput.lines[0].antigrainMaxIndex, 4)

        ele = antigrain.element(in: polylineOutput.lines[0], at: 3)

        XCTAssertEqual(ele, .curveTo(point: polylineOutput.lines[0].points[3],
                                     ctrl1: CGPoint(x: 336.9504831500294, y: 140.76237921249262),
                                     ctrl2: CGPoint(x: 363.39180836637934, y: 105.49122874504309)))

        ele = antigrain.element(in: polylineOutput.lines[0], at: 4)

        XCTAssertEqual(ele, .curveTo(point: polylineOutput.lines[0].points[4],
                                     ctrl1: CGPoint(x: 433.39180836637934, y: 94.99122874504309),
                                     ctrl2: CGPoint(x: 465, y: 113)))
    }
}
