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

    func testSplitAfterPrediction() throws {
        let touchId: UITouchIdentifier = UUID().uuidString
        let completeEvents = [Event(id: touchId, loc: CGPoint(x: 100, y: 100), pred: false, update: EstimationUpdateIndex(1)),
                              Event(id: touchId, loc: CGPoint(x: 200, y: 100), pred: true),
                              Event(id: touchId, loc: CGPoint(x: 110, y: 120), pred: false, update: EstimationUpdateIndex(1)),
                              Event(id: touchId, loc: CGPoint(x: 200, y: 100), pred: false, update: EstimationUpdateIndex(2)),
                              Event(id: touchId, loc: CGPoint(x: 220, y: 120), pred: false, update: EstimationUpdateIndex(2))]
        let events = TouchEvent.newFrom(completeEvents)

        let touchStream = TouchPointStream()
        let output = touchStream.process(touchEvents: events)

        XCTAssertEqual(output.deltas.count, 2)
        XCTAssertEqual(output.deltas[0], .addedTouchPoints(pointCollectionIndex: 0))
        XCTAssertEqual(output.deltas[1], .completedTouchPoints(pointCollectionIndex: 0))

        let altStream = TouchPointStream()
        let altOutput1 = altStream.process(touchEvents: Array(events[0 ..< 2]))
        let altOutput2 = altStream.process(touchEvents: Array(events[2...]))

        XCTAssertEqual(altOutput1.deltas.count, 1)
        XCTAssertEqual(altOutput1.deltas[0], .addedTouchPoints(pointCollectionIndex: 0))

        XCTAssertEqual(altOutput2.deltas.count, 2)
        XCTAssertEqual(altOutput2.deltas[0], .updatedTouchPoints(pointCollectionIndex: 0, updatedIndexes: IndexSet([0, 1])))
        XCTAssertEqual(altOutput2.deltas[1], .completedTouchPoints(pointCollectionIndex: 0))

        XCTAssertEqual(touchStream.pointCollections, altStream.pointCollections)
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

        for split in 1..<events.count {
            let altStream = TouchPointStream()
            altStream.process(touchEvents: Array(events[0 ..< split]))
            altStream.process(touchEvents: Array(events[split ..< events.count]))

            XCTAssertEqual(touchStream.pointCollections, altStream.pointCollections, "match fails in split(\(split)))")
        }
    }

    func testStreamsMatch2() throws {
        let testBundle = Bundle(for: type(of: self))
        guard
            let jsonFile = testBundle.url(forResource: "events", withExtension: "json")
        else {
            XCTFail("Could not load json")
            return
        }

        let data = try Data(contentsOf: jsonFile)
        let events = try JSONDecoder().decode([TouchEvent].self, from: data)
        let touchStream = TouchPointStream()
        touchStream.process(touchEvents: events)

        for split in 1..<events.count {
            let altStream = TouchPointStream()
            altStream.process(touchEvents: Array(events[0 ..< split]))
            altStream.process(touchEvents: Array(events[split ..< events.count]))

            XCTAssertEqual(touchStream.pointCollections, altStream.pointCollections)
        }
    }

    func testMeasureTouchEvents() throws {
        let testBundle = Bundle(for: type(of: self))
        guard
            let jsonFile = testBundle.url(forResource: "events", withExtension: "json")
        else {
            XCTFail("Could not load json")
            return
        }

        let data = try Data(contentsOf: jsonFile)
        let events = try JSONDecoder().decode([TouchEvent].self, from: data)

        measure {
            let touchStream = TouchPointStream()
            let midPoint = events.count / 2
            touchStream.process(touchEvents: Array(events[0 ..< midPoint]))
            touchStream.process(touchEvents: Array(events[midPoint...]))
        }
    }

    func testStreamsMatch3() throws {
        let touchId: UITouchIdentifier = UUID().uuidString
        let completeEvents = [Event(id: touchId, loc: CGPoint(x: 100, y: 100), pred: false, update: EstimationUpdateIndex(1)),
                              Event(id: touchId, loc: CGPoint(x: 200, y: 100), pred: true),
                              Event(id: touchId, loc: CGPoint(x: 300, y: 100), pred: true),
                              Event(id: touchId, loc: CGPoint(x: 110, y: 120), pred: false, update: EstimationUpdateIndex(1)),
                              Event(id: touchId, loc: CGPoint(x: 200, y: 100), pred: false, update: EstimationUpdateIndex(2)),
                              Event(id: touchId, loc: CGPoint(x: 220, y: 120), pred: false, update: EstimationUpdateIndex(2)),
                              Event(id: touchId, loc: CGPoint(x: 320, y: 120), pred: false)]
        let events = TouchEvent.newFrom(completeEvents)

        let touchStream = TouchPointStream()
        touchStream.process(touchEvents: events)

        for split in 2..<events.count {
            let altStream = TouchPointStream()
            altStream.process(touchEvents: Array(events[0 ..< split]))
            altStream.process(touchEvents: Array(events[split ..< events.count]))

            XCTAssertEqual(touchStream.pointCollections, altStream.pointCollections)
        }
    }

    func testRemovePredicted() throws {
        let touchId: UITouchIdentifier = UUID().uuidString
        let completeEvents = [Event(id: touchId, loc: CGPoint(x: 100, y: 100), pred: false, update: EstimationUpdateIndex(1)),
                              Event(id: touchId, loc: CGPoint(x: 200, y: 100), pred: true),
                              Event(id: touchId, loc: CGPoint(x: 300, y: 100), pred: true),
                              Event(id: touchId, loc: CGPoint(x: 110, y: 120), pred: false, update: EstimationUpdateIndex(1))]
        let events = TouchEvent.newFrom(completeEvents)
        let touchStream = TouchPointStream()
        let output = touchStream.process(touchEvents: events)

        XCTAssertEqual(output.deltas.count, 2)
        XCTAssertEqual(output.deltas[0], .addedTouchPoints(pointCollectionIndex: 0))
        XCTAssertEqual(output.deltas[1], .completedTouchPoints(pointCollectionIndex: 0))

        let altStream = TouchPointStream()
        let altOutput1 = altStream.process(touchEvents: Array(events[0 ... 2]))
        let altOutput2 = altStream.process(touchEvents: Array(events[3...]))

        XCTAssertEqual(altOutput1.deltas.count, 1)
        XCTAssertEqual(altOutput1.deltas[0], .addedTouchPoints(pointCollectionIndex: 0))

        XCTAssertEqual(altOutput2.deltas.count, 2)
        XCTAssertEqual(altOutput2.deltas[0], .updatedTouchPoints(pointCollectionIndex: 0, updatedIndexes: IndexSet([0, 1, 2])))
        XCTAssertEqual(altOutput2.deltas[1], .completedTouchPoints(pointCollectionIndex: 0))

        XCTAssertEqual(altOutput2.pointCollections.count, 1)
        XCTAssertEqual(altOutput2.pointCollections[0].points.count, 1)

        XCTAssertEqual(touchStream.pointCollections, altStream.pointCollections)
    }

    func testCorrectPointCountAndLocation() throws {
        let touchId: UITouchIdentifier = UUID().uuidString
        let completeEvents = [Event(id: touchId, loc: CGPoint(x: 100, y: 100), pred: false, update: EstimationUpdateIndex(1)),
                              Event(id: touchId, loc: CGPoint(x: 200, y: 100), pred: true),
                              Event(id: touchId, loc: CGPoint(x: 110, y: 120), pred: false, update: EstimationUpdateIndex(1)),
                              Event(id: touchId, loc: CGPoint(x: 200, y: 110), pred: false, update: EstimationUpdateIndex(2)),
                              Event(id: touchId, loc: CGPoint(x: 220, y: 120), pred: false, update: EstimationUpdateIndex(2))]
        var events = TouchEvent.newFrom(completeEvents)

        let touchStream = TouchPointStream()
        var output = touchStream.process(touchEvents: [events.removeFirst()])

        XCTAssertEqual(output.pointCollections.count, 1)
        XCTAssertEqual(output.pointCollections[0].touchIdentifier, touchId)
        XCTAssertEqual(output.pointCollections[0].isComplete, false)
        XCTAssertEqual(output.pointCollections[0].points.count, 1)
        XCTAssertEqual(output.pointCollections[0].points[0].events.count, 1)
        XCTAssertEqual(output.pointCollections[0].points[0].event.location, CGPoint(x: 100, y: 100))

        output = touchStream.process(touchEvents: [events.removeFirst()])

        XCTAssertEqual(output.pointCollections.count, 1)
        XCTAssertEqual(output.pointCollections[0].isComplete, false)
        XCTAssertEqual(output.pointCollections[0].points.count, 2)
        XCTAssertEqual(output.pointCollections[0].points[0].events.count, 1)
        XCTAssertEqual(output.pointCollections[0].points[0].event.location, CGPoint(x: 100, y: 100))
        XCTAssertEqual(output.pointCollections[0].points[1].events.count, 1)
        XCTAssertEqual(output.pointCollections[0].points[1].event.location, CGPoint(x: 200, y: 100))

        output = touchStream.process(touchEvents: [events.removeFirst(), events.removeFirst()])

        XCTAssertEqual(output.pointCollections.count, 1)
        XCTAssertEqual(output.pointCollections[0].isComplete, false)
        XCTAssertEqual(output.pointCollections[0].points.count, 2)
        XCTAssertEqual(output.pointCollections[0].points[0].events.count, 2)
        XCTAssertEqual(output.pointCollections[0].points[0].event.location, CGPoint(x: 110, y: 120))
        XCTAssertEqual(output.pointCollections[0].points[1].events.count, 2)
        XCTAssertEqual(output.pointCollections[0].points[1].event.location, CGPoint(x: 200, y: 110))

        output = touchStream.process(touchEvents: [events.removeFirst()])

        XCTAssertEqual(output.pointCollections.count, 1)
        XCTAssertEqual(output.pointCollections[0].isComplete, true)
        XCTAssertEqual(output.pointCollections[0].points.count, 2)
        XCTAssertEqual(output.pointCollections[0].points[0].events.count, 2)
        XCTAssertEqual(output.pointCollections[0].points[0].event.location, CGPoint(x: 110, y: 120))
        XCTAssertEqual(output.pointCollections[0].points[1].events.count, 3)
        XCTAssertEqual(output.pointCollections[0].points[1].event.location, CGPoint(x: 220, y: 120))
    }

    func testCorrectPointSplitPrediction() throws {
        let touchId: UITouchIdentifier = UUID().uuidString
        let completeEvents = [Event(id: touchId, loc: CGPoint(x: 100, y: 100), pred: false, update: EstimationUpdateIndex(1)),
                              Event(id: touchId, loc: CGPoint(x: 200, y: 100), pred: true),
                              Event(id: touchId, loc: CGPoint(x: 300, y: 100), pred: true),
                              Event(id: touchId, loc: CGPoint(x: 110, y: 120), pred: false, update: EstimationUpdateIndex(1)),
                              Event(id: touchId, loc: CGPoint(x: 200, y: 110), pred: false, update: EstimationUpdateIndex(2)),
                              Event(id: touchId, loc: CGPoint(x: 220, y: 120), pred: false, update: EstimationUpdateIndex(2))]
        var events = TouchEvent.newFrom(completeEvents)

        let touchStream = TouchPointStream()
        var output = touchStream.process(touchEvents: [events.removeFirst()])

        XCTAssertEqual(output.pointCollections.count, 1)
        XCTAssertEqual(output.pointCollections[0].touchIdentifier, touchId)
        XCTAssertEqual(output.pointCollections[0].isComplete, false)
        XCTAssertEqual(output.pointCollections[0].points.count, 1)
        XCTAssertEqual(output.pointCollections[0].points[0].events.count, 1)
        XCTAssertEqual(output.pointCollections[0].points[0].event.location, CGPoint(x: 100, y: 100))

        output = touchStream.process(touchEvents: [events.removeFirst()])

        XCTAssertEqual(output.pointCollections.count, 1)
        XCTAssertEqual(output.pointCollections[0].isComplete, false)
        XCTAssertEqual(output.pointCollections[0].points.count, 2)
        XCTAssertEqual(output.pointCollections[0].points[0].events.count, 1)
        XCTAssertEqual(output.pointCollections[0].points[0].event.location, CGPoint(x: 100, y: 100))
        XCTAssertEqual(output.pointCollections[0].points[1].events.count, 1)
        XCTAssertEqual(output.pointCollections[0].points[1].event.location, CGPoint(x: 200, y: 100))

        output = touchStream.process(touchEvents: [events.removeFirst()])

        XCTAssertEqual(output.pointCollections.count, 1)
        XCTAssertEqual(output.pointCollections[0].isComplete, false)
        XCTAssertEqual(output.pointCollections[0].points.count, 3)
        XCTAssertEqual(output.pointCollections[0].points[0].events.count, 1)
        XCTAssertEqual(output.pointCollections[0].points[0].event.location, CGPoint(x: 100, y: 100))
        XCTAssertEqual(output.pointCollections[0].points[1].events.count, 1)
        XCTAssertEqual(output.pointCollections[0].points[1].event.location, CGPoint(x: 200, y: 100))
        XCTAssertEqual(output.pointCollections[0].points[2].events.count, 1)
        XCTAssertEqual(output.pointCollections[0].points[2].event.location, CGPoint(x: 300, y: 100))

        // consume 2 events
        output = touchStream.process(touchEvents: [events.removeFirst(), events.removeFirst()])

        XCTAssertEqual(output.pointCollections.count, 1)
        XCTAssertEqual(output.pointCollections[0].isComplete, false)
        XCTAssertEqual(output.pointCollections[0].points.count, 2)
        XCTAssertEqual(output.pointCollections[0].points[0].events.count, 2)
        XCTAssertEqual(output.pointCollections[0].points[0].event.location, CGPoint(x: 110, y: 120))
        XCTAssertEqual(output.pointCollections[0].points[1].events.count, 2)
        XCTAssertEqual(output.pointCollections[0].points[1].event.location, CGPoint(x: 200, y: 110))

        output = touchStream.process(touchEvents: [events.removeFirst()])

        XCTAssertEqual(output.pointCollections.count, 1)
        XCTAssertEqual(output.pointCollections[0].isComplete, true)
        XCTAssertEqual(output.pointCollections[0].points.count, 2)
        XCTAssertEqual(output.pointCollections[0].points[0].events.count, 2)
        XCTAssertEqual(output.pointCollections[0].points[0].event.location, CGPoint(x: 110, y: 120))
        XCTAssertEqual(output.pointCollections[0].points[1].events.count, 3)
        XCTAssertEqual(output.pointCollections[0].points[1].event.location, CGPoint(x: 220, y: 120))
    }

    func testCorrectPointsMultipleLines() throws {
        let touchId1: UITouchIdentifier = UUID().uuidString
        let touchId2: UITouchIdentifier = UUID().uuidString
        let completeEvents = [Event(id: touchId1, loc: CGPoint(x: 100, y: 100), pred: false, update: EstimationUpdateIndex(3)),
                              Event(id: touchId1, loc: CGPoint(x: 200, y: 100), pred: true),
                              Event(id: touchId1, loc: CGPoint(x: 110, y: 120), pred: false, update: EstimationUpdateIndex(3)),
                              Event(id: touchId2, loc: CGPoint(x: 100, y: 100), pred: false, update: EstimationUpdateIndex(1)),
                              Event(id: touchId2, loc: CGPoint(x: 200, y: 100), pred: true),
                              Event(id: touchId2, loc: CGPoint(x: 110, y: 120), pred: false, update: EstimationUpdateIndex(1)),
                              Event(id: touchId1, loc: CGPoint(x: 200, y: 110), pred: false, update: EstimationUpdateIndex(2)),
                              Event(id: touchId1, loc: CGPoint(x: 220, y: 120), pred: false, update: EstimationUpdateIndex(2)),
                              Event(id: touchId2, loc: CGPoint(x: 200, y: 110), pred: false, update: EstimationUpdateIndex(4)),
                              Event(id: touchId2, loc: CGPoint(x: 220, y: 120), pred: false, update: EstimationUpdateIndex(4))]
        let events = TouchEvent.newFrom(completeEvents)

        let touchStream = TouchPointStream()
        var output = touchStream.process(touchEvents: Array(events[0 ..< 3]))

        XCTAssertEqual(output.pointCollections.count, 1)
        XCTAssertEqual(output.pointCollections[0].touchIdentifier, touchId1)
        XCTAssertEqual(output.pointCollections[0].isComplete, false)
        XCTAssertEqual(output.pointCollections[0].points.count, 1)
        XCTAssertEqual(output.pointCollections[0].points[0].events.count, 2)
        XCTAssertEqual(output.pointCollections[0].points[0].event.location, CGPoint(x: 110, y: 120))

        XCTAssertEqual(output.deltas.count, 1)
        XCTAssertEqual(output.deltas[0], .addedTouchPoints(pointCollectionIndex: 0))

        output = touchStream.process(touchEvents: Array(events[3 ..< 6]))

        XCTAssertEqual(output.pointCollections.count, 2)
        XCTAssertEqual(output.pointCollections[1].touchIdentifier, touchId2)
        XCTAssertEqual(output.pointCollections[1].isComplete, false)
        XCTAssertEqual(output.pointCollections[1].points.count, 1)
        XCTAssertEqual(output.pointCollections[1].points[0].events.count, 2)
        XCTAssertEqual(output.pointCollections[1].points[0].event.location, CGPoint(x: 110, y: 120))

        XCTAssertEqual(output.deltas.count, 1)
        XCTAssertEqual(output.deltas[0], .addedTouchPoints(pointCollectionIndex: 1))

        output = touchStream.process(touchEvents: Array(events[6...]))

        XCTAssertEqual(output.pointCollections.count, 2)
        XCTAssertEqual(output.pointCollections[0].isComplete, true)
        XCTAssertEqual(output.pointCollections[0].points.count, 2)
        XCTAssertEqual(output.pointCollections[0].points[0].events.count, 2)
        XCTAssertEqual(output.pointCollections[0].points[0].event.location, CGPoint(x: 110, y: 120))
        XCTAssertEqual(output.pointCollections[0].points[1].events.count, 3)
        XCTAssertEqual(output.pointCollections[0].points[1].event.location, CGPoint(x: 220, y: 120))

        XCTAssertEqual(output.pointCollections[1].isComplete, true)
        XCTAssertEqual(output.pointCollections[1].points.count, 2)
        XCTAssertEqual(output.pointCollections[1].points[0].events.count, 2)
        XCTAssertEqual(output.pointCollections[1].points[0].event.location, CGPoint(x: 110, y: 120))
        XCTAssertEqual(output.pointCollections[1].points[1].events.count, 3)
        XCTAssertEqual(output.pointCollections[1].points[1].event.location, CGPoint(x: 220, y: 120))

        XCTAssertEqual(output.deltas.count, 4)
        XCTAssertEqual(output.deltas[0], .updatedTouchPoints(pointCollectionIndex: 0, updatedIndexes: IndexSet([1])))
        XCTAssertEqual(output.deltas[1], .completedTouchPoints(pointCollectionIndex: 0))
        XCTAssertEqual(output.deltas[2], .updatedTouchPoints(pointCollectionIndex: 1, updatedIndexes: IndexSet([1])))
        XCTAssertEqual(output.deltas[3], .completedTouchPoints(pointCollectionIndex: 1))
    }
}
