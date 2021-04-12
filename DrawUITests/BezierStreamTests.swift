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

class BezierStreamTests: XCTestCase {
    static let pen = AttributesStream.ToolStyle(width: 1.5, color: .black)
    static let eraser = AttributesStream.ToolStyle(width: 10, color: nil)

    func buildAttributeStream() -> AttributesStream {
        let attributeStream = AttributesStream()
        attributeStream.styleOverride = { delta in
            switch delta {
            case .addedBezierPath(let index):
                return index == 0 ? Self.pen : Self.eraser
            default:
                return nil
            }
        }
        return attributeStream
    }

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

        let bezierStream = BezierStream(smoother: AntigrainSmoother())
        let attributeStream = buildAttributeStream()

        let bezierOutput = bezierStream.produce(with: polylineOutput)
        let attributedOutput = attributeStream.produce(with: bezierOutput)

        XCTAssert(polylineOutput.lines[0] == attributedOutput.paths[0])
        XCTAssert(attributedOutput.paths[0].color == .black)
        XCTAssert(attributedOutput.paths[0].lineWidth == 1.5)
        XCTAssertEqual(attributedOutput.deltas[0], .addedBezierPath(index: 0))
    }

    func testGeneratedLines() throws {
        let simpleEvents = Event.events(from: CGPoint(x: 100, y: 100), to: CGPoint(x: 200, y: 100))
        let touchEvents = TouchEvent.newFrom(simpleEvents)

        let touchPathStream = TouchPathStream()
        let polylineStream = PolylineStream()
        let bezierStream = BezierStream(smoother: AntigrainSmoother())
        let attributeStream = buildAttributeStream()

        let touchPathOutput = touchPathStream.produce(with: touchEvents)
        let polylineOutput = polylineStream.produce(with: touchPathOutput)
        let bezierOutput = bezierStream.produce(with: polylineOutput)
        let attributedOutput = attributeStream.produce(with: bezierOutput)

        XCTAssertEqual(attributedOutput.paths.count, 1)
        XCTAssertEqual(attributedOutput.deltas.count, 2)

        XCTAssert(polylineOutput.lines[0] == attributedOutput.paths[0])
        XCTAssert(attributedOutput.paths[0].color == .black)
        XCTAssertEqual(attributedOutput.deltas[0], .addedBezierPath(index: 0))
        XCTAssertEqual(attributedOutput.deltas[1], .completedBezierPath(index: 0))
    }
}
