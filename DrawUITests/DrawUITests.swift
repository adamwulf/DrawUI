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
        let touchId = UUID().uuidString
        let startTouch = TouchEvent(touchIdentifier: touchId,
                                    phase: .began,
                                    location: CGPoint(x: 100, y: 100),
                                    estimationUpdateIndex: NSNumber(1),
                                    estimatedProperties: UITouch.Properties.location,
                                    estimatedPropertiesExpectingUpdates: UITouch.Properties.location,
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
                                      estimationUpdateIndex: NSNumber(1),
                                      estimatedProperties: UITouch.Properties(rawValue: 0),
                                      estimatedPropertiesExpectingUpdates: UITouch.Properties(rawValue: 0),
                                      isUpdate: true,
                                      isPrediction: false)

        let strokes = Strokes()
        let delta1 = strokes.add(touchEvents: [startTouch, predictedTouch])

        XCTAssertEqual(delta1.count, 1)
        if case .addedStroke(let stroke) = delta1.first {
            XCTAssertEqual(stroke.points.count, 2)
            XCTAssertEqual(stroke.points.first!.event.location, CGPoint(x: 100, y: 100))
            XCTAssertEqual(stroke.points.last!.event.location, CGPoint(x: 200, y: 100))
            XCTAssert(stroke.points.first!.expectsUpdate)
            XCTAssert(stroke.points.last!.expectsUpdate)
        } else {
            XCTFail()
        }

        let delta2 = strokes.add(touchEvents: [updatedTouch])

        XCTAssertEqual(delta2.count, 1)
        if case .updatedStroke(let stroke, let indexSet) = delta2.first {
            XCTAssertEqual(stroke.points.count, 1)
            XCTAssertEqual(indexSet.count, 2)
            XCTAssertEqual(indexSet.first!, 0)
            XCTAssertEqual(indexSet.last!, 1)
            XCTAssertEqual(stroke.points.first!.event.location, CGPoint(x: 110, y: 120))
            XCTAssert(!stroke.points.first!.expectsUpdate)
        } else {
            XCTFail()
        }
    }
}
