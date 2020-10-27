//
//  DrawUITests.swift
//  DrawUITests
//
//  Created by Adam Wulf on 8/16/20.
//

import XCTest
import DrawUI

class DrawUITests: XCTestCase {

    func testSingleStrokeWithUpdate() throws {
        // Input:
        // event batch 1 contains:
        //     a) a point expecting a location update
        //     b) a predicted point
        // event batch 2 contains:
        //     a) an update to the (a) point above
        // event batch 3 contains:
        //     a) a .ended point expecting an update (the stroke should not be complete yet)
        // event batch 4 contains:
        //     a) the location update for (a) above, completing the stroke
        //
        // since a new point event didn't arrive for the prediction,
        // that point is removed. its index is included in the IndexSet
        // of modified points.
        let touchId: UITouchIdentifier = UUID().uuidString
        let startTouch = TouchEvent(touchIdentifier: touchId,
                                    phase: .began,
                                    location: CGPoint(x: 100, y: 100),
                                    estimationUpdateIndex: EstimationUpdateIndex(1),
                                    estimatedProperties: .location,
                                    estimatedPropertiesExpectingUpdates: .location,
                                    isUpdate: false,
                                    isPrediction: false)
        let predictedTouch = TouchEvent(touchIdentifier: touchId,
                                        phase: .moved,
                                        location: CGPoint(x: 200, y: 100),
                                        estimationUpdateIndex: nil,
                                        estimatedProperties: .none,
                                        estimatedPropertiesExpectingUpdates: .none,
                                        isUpdate: false,
                                        isPrediction: true)
        let updatedTouch = TouchEvent(touchIdentifier: touchId,
                                      phase: .began,
                                      location: CGPoint(x: 110, y: 120),
                                      estimationUpdateIndex: EstimationUpdateIndex(1),
                                      estimatedProperties: .none,
                                      estimatedPropertiesExpectingUpdates: .none,
                                      isUpdate: true,
                                      isPrediction: false)
        let lastTouch = TouchEvent(touchIdentifier: touchId,
                                   phase: .ended,
                                   location: CGPoint(x: 200, y: 100),
                                   estimationUpdateIndex: EstimationUpdateIndex(2),
                                   estimatedProperties: .location,
                                   estimatedPropertiesExpectingUpdates: .location,
                                   isUpdate: false,
                                   isPrediction: false)
        let lastUpdatedTouch = TouchEvent(touchIdentifier: touchId,
                                      phase: .ended,
                                      location: CGPoint(x: 220, y: 120),
                                      estimationUpdateIndex: EstimationUpdateIndex(2),
                                      estimatedProperties: .location,
                                      estimatedPropertiesExpectingUpdates: .none,
                                      isUpdate: true,
                                      isPrediction: false)

        let pointStream = TouchPointStream()
        var output = pointStream.process(touchEvents: [startTouch, predictedTouch])
        let delta1 = output.deltas

        XCTAssertEqual(delta1.count, 1)
        if case .addedTouchPoints(let index) = delta1.first {
            XCTAssertEqual(output.pointCollections[index].points.count, 2)
            XCTAssertEqual(output.pointCollections[index].points.first!.event.location, CGPoint(x: 100, y: 100))
            XCTAssertEqual(output.pointCollections[index].points.last!.event.location, CGPoint(x: 200, y: 100))
            XCTAssert(output.pointCollections[index].points.first!.expectsUpdate)
            XCTAssert(output.pointCollections[index].points.last!.expectsUpdate)
        } else {
            XCTFail()
        }

        output = pointStream.process(touchEvents: [updatedTouch])
        let delta2 = output.deltas

        XCTAssertEqual(output.pointCollections.count, 1)
        XCTAssertEqual(delta2.count, 1)
        if case .updatedTouchPoints(let index, let indexSet) = delta2.first {
            XCTAssertEqual(output.pointCollections[index].points.count, 1)
            XCTAssertEqual(indexSet.count, 2)
            XCTAssertEqual(indexSet.first!, 0)
            XCTAssertEqual(indexSet.last!, 1)
            XCTAssertEqual(output.pointCollections[index].points.first!.event.location, CGPoint(x: 110, y: 120))
            XCTAssert(!output.pointCollections[index].points.first!.expectsUpdate)
        } else {
            XCTFail()
        }

        output = pointStream.process(touchEvents: [lastTouch])
        let delta3 = output.deltas

        XCTAssertEqual(output.pointCollections.count, 1)
        XCTAssertEqual(delta3.count, 1)
        if case .updatedTouchPoints(let index, let indexSet) = delta3.first {
            XCTAssertEqual(output.pointCollections[index].points.count, 2)
            XCTAssertEqual(indexSet.count, 1)
            XCTAssertEqual(indexSet.first!, 1)
            XCTAssertEqual(output.pointCollections[index].points.last!.event.location, CGPoint(x: 200, y: 100))
            XCTAssert(output.pointCollections[index].points.last!.expectsUpdate)
            XCTAssertFalse(output.pointCollections[index].isComplete)
        } else {
            XCTFail()
        }

        output = pointStream.process(touchEvents: [lastUpdatedTouch])
        let delta4 = output.deltas

        XCTAssertEqual(output.pointCollections.count, 1)
        XCTAssertEqual(delta4.count, 2)
        if case .updatedTouchPoints(let index, let indexSet) = delta4.first {
            XCTAssertEqual(output.pointCollections[index].points.count, 2)
            XCTAssertEqual(indexSet.count, 1)
            XCTAssertEqual(indexSet.first!, 1)
            XCTAssertEqual(output.pointCollections[index].points.last!.event.location, CGPoint(x: 220, y: 120))
            XCTAssert(!output.pointCollections[index].points.last!.expectsUpdate)
            XCTAssertTrue(output.pointCollections[index].isComplete)
        } else {
            XCTFail()
        }

        if case .completedTouchPoints(let index) = delta4.last {
            XCTAssertTrue(output.pointCollections[index].isComplete)
        } else {
            XCTFail()
        }
    }

    func testSimpleStroke() {
        let touchId: UITouchIdentifier = UUID().uuidString
        let simpleEvents = [(id: touchId, loc: CGPoint(x: 4, y: 10)),
                            (id: touchId, loc: CGPoint(x: 10, y: 100)),
                            (id: touchId, loc: CGPoint(x: 12, y: 40)),
                            (id: touchId, loc: CGPoint(x: 16, y: 600))]
        let events = TouchEvent.newFrom(simpleEvents)

        XCTAssertEqual(events.count, 4)
        XCTAssertEqual(events[0].phase, .began)
        XCTAssertEqual(events[1].phase, .moved)
        XCTAssertEqual(events[2].phase, .moved)
        XCTAssertEqual(events[3].phase, .ended)

        XCTAssertEqual(events[0].location, simpleEvents[0].loc)
        XCTAssertEqual(events[1].location, simpleEvents[1].loc)
        XCTAssertEqual(events[2].location, simpleEvents[2].loc)
        XCTAssertEqual(events[3].location, simpleEvents[3].loc)

        XCTAssert(events.matches(simpleEvents))
        XCTAssert(events.matches(simpleEvents.phased()))
    }

    func testTwoStrokes() {
        let touchId1: UITouchIdentifier = UUID().uuidString
        let touchId2: UITouchIdentifier = UUID().uuidString
        let simpleEvents = [(id: touchId1, loc: CGPoint(x: 4, y: 10)),
                            (id: touchId1, loc: CGPoint(x: 10, y: 100)),
                            (id: touchId2, loc: CGPoint(x: 12, y: 40)),
                            (id: touchId1, loc: CGPoint(x: 16, y: 600)),
                            (id: touchId2, loc: CGPoint(x: 4, y: 10)),
                            (id: touchId2, loc: CGPoint(x: 10, y: 100)),
                            (id: touchId1, loc: CGPoint(x: 12, y: 40)),
                            (id: touchId2, loc: CGPoint(x: 16, y: 600))]
        let events = TouchEvent.newFrom(simpleEvents)
        let str1 = events.having(id: touchId1)
        let str2 = events.having(id: touchId2)

        for str in [str1, str2] {
            XCTAssertEqual(str.count, 4)
            XCTAssertEqual(str[0].phase, .began)
            XCTAssertEqual(str[1].phase, .moved)
            XCTAssertEqual(str[2].phase, .moved)
            XCTAssertEqual(str[3].phase, .ended)
        }

        XCTAssert(events.matches(simpleEvents))
    }
}
