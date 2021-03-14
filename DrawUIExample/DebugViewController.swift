//
//  DebugViewController.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 8/16/20.
//

import UIKit
import DrawUI

class DebugViewController: UIViewController {

    var allEvents: [TouchEvent] = []

    let eventStream: TouchEventStream
    let pointStream: TouchPathStream
    let strokeStream: PolylineStream
    @IBOutlet var debugView: DebugView!

    let savitzkyGolay = NaiveSavitzkyGolay()
    let douglasPeucker = NaiveDouglasPeucker()
    let pointDistance = NaivePointDistance()

    required init?(coder: NSCoder) {
        eventStream = TouchEventStream()
        pointStream = TouchPathStream()
        strokeStream = PolylineStream()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let exportButton = UIButton()
        exportButton.setTitle("Export", for: .normal)
        exportButton.setTitleColor(.systemBlue, for: .normal)
        view.addSubview(exportButton)
        exportButton.translatesAutoresizingMaskIntoConstraints = false
        exportButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        exportButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        exportButton.addTarget(self, action: #selector(didRequestExport), for: .touchUpInside)

        eventStream.eventStreamChanged = { [weak self] (updatedEvents) in
            guard let self = self else { return }
            self.allEvents.append(contentsOf: updatedEvents)
            let pointOutput = self.pointStream.process(touchEvents: updatedEvents)
            let strokeOutput = self.strokeStream.process(input: pointOutput)
            let douglasPeuckerOutput = self.douglasPeucker.process(input: strokeOutput)
            let pointDistanceOutput = self.pointDistance.process(input: douglasPeuckerOutput)
            let smoothOutput = self.savitzkyGolay.process(input: pointDistanceOutput)

            self.debugView?.originalStrokes = strokeOutput.lines
            self.debugView?.smoothStrokes = smoothOutput.lines
            self.debugView?.add(deltas: strokeOutput.deltas)
            self.debugView?.setNeedsDisplay()
        }

        debugView?.addGestureRecognizer(eventStream.gesture)
    }
}

extension DebugViewController {

    private func resmoothEverything() {
        // If any of the settings have changed or been reenabled, etc.
        let originalOutput: PolylineStream.Output = (lines: strokeStream.lines, deltas: [])
        let douglasPeuckerOutput = self.douglasPeucker.process(input: originalOutput)
        let pointDistanceOutput = self.pointDistance.process(input: douglasPeuckerOutput)
        let smoothOutput = self.savitzkyGolay.process(input: pointDistanceOutput)
        debugView.smoothStrokes = smoothOutput.lines
        debugView.setNeedsDisplay()
    }

    func didChangeSettings() {
        resmoothEverything()
    }

    @objc func didRequestExport(_ sender: UIView) {
        let tmpDirURL = FileManager.default.temporaryDirectory.appendingPathComponent("events").appendingPathExtension("json")
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.withoutEscapingSlashes, .prettyPrinted]

        if let json = try? jsonEncoder.encode(allEvents) {
            do {
                try json.write(to: tmpDirURL)

                let sharevc = UIActivityViewController(activityItems: [tmpDirURL], applicationActivities: nil)
                sharevc.popoverPresentationController?.sourceView = sender
                present(sharevc, animated: true, completion: nil)
            } catch {
                // ignore
            }
        }
    }
}
