//
//  TouchPointStreamTests.swift
//  DrawUITests
//
//  Created by Adam Wulf on 10/27/20.
//

import XCTest
import DrawUI

class TouchPointStreamTests: XCTestCase {

    typealias Event = TouchEvent.Simple

    func testJSONEncodeAndDecode() throws {
        let touchId: UITouchIdentifier = UUID().uuidString
        let completeEvents = [Event(id: touchId, loc: CGPoint(x: 100, y: 100), pred: false, update: EstimationUpdateIndex(1)),
                              Event(id: touchId, loc: CGPoint(x: 200, y: 100), pred: true),
                              Event(id: touchId, loc: CGPoint(x: 110, y: 120), pred: false, update: EstimationUpdateIndex(1)),
                              Event(id: touchId, loc: CGPoint(x: 200, y: 100), pred: false, update: EstimationUpdateIndex(2)),
                              Event(id: touchId, loc: CGPoint(x: 220, y: 120), pred: false, update: EstimationUpdateIndex(2))]
        let events = TouchEvent.newFrom(completeEvents)

        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.withoutEscapingSlashes, .prettyPrinted]
        guard let json = try? jsonEncoder.encode(events) else { XCTFail("Failed encoding json"); return }
        guard let decodedEvents = try? JSONDecoder().decode([TouchEvent].self, from: json) else { XCTFail("Failed decoding json"); return }

        XCTAssertEqual(events, decodedEvents)
    }

    func testStreamsMatch() throws {
        let touchId: UITouchIdentifier = UUID().uuidString
        let completeEvents = [Event(id: touchId, loc: CGPoint(x: 100, y: 100), pred: false, update: EstimationUpdateIndex(1)),
                              Event(id: touchId, loc: CGPoint(x: 200, y: 100), pred: true),
                              Event(id: touchId, loc: CGPoint(x: 110, y: 120), pred: false, update: EstimationUpdateIndex(1)),
                              Event(id: touchId, loc: CGPoint(x: 200, y: 100), pred: false, update: EstimationUpdateIndex(2)),
                              Event(id: touchId, loc: CGPoint(x: 220, y: 120), pred: false, update: EstimationUpdateIndex(2))]
        let events = TouchEvent.newFrom(completeEvents)

        let touchStream = TouchPointStream()
        touchStream.process(touchEvents: events)

        for split in 1..<completeEvents.count {
            let altStream = TouchPointStream()
            altStream.process(touchEvents: Array(events[0 ..< split]))
            altStream.process(touchEvents: Array(events[split ..< completeEvents.count]))

            XCTAssertEqual(touchStream.pointCollections, altStream.pointCollections)
        }
    }
}
