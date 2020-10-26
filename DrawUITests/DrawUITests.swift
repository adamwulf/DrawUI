//
//  DrawUITests.swift
//  DrawUITests
//
//  Created by Adam Wulf on 8/16/20.
//

import XCTest
import DrawUI

class DrawUITests: XCTestCase {

    func testExample() throws {
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
                                        estimatedProperties: UITouch.Properties(rawValue: 0),
                                        estimatedPropertiesExpectingUpdates: UITouch.Properties(rawValue: 0),
                                        isUpdate: false,
                                        isPrediction: true)
        let updatedTouch = TouchEvent(touchIdentifier: touchId,
                                      phase: .began,
                                      location: CGPoint(x: 110, y: 120),
                                      estimationUpdateIndex: EstimationUpdateIndex(1),
                                      estimatedProperties: UITouch.Properties(rawValue: 0),
                                      estimatedPropertiesExpectingUpdates: UITouch.Properties(rawValue: 0),
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
                                      estimatedPropertiesExpectingUpdates: UITouch.Properties(rawValue: 0),
                                      isUpdate: true,
                                      isPrediction: false)

        let strokes = TouchPointStream()
        var output = strokes.process(touchEvents: [startTouch, predictedTouch])
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

        output = strokes.process(touchEvents: [updatedTouch])
        let delta2 = output.deltas

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

        output = strokes.process(touchEvents: [lastTouch])
        let delta3 = output.deltas

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

        output = strokes.process(touchEvents: [lastUpdatedTouch])
        let delta4 = output.deltas

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
}
