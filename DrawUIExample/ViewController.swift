//
//  ViewController.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 8/16/20.
//

import UIKit
import DrawUI
import Former

class ViewController: UIViewController {

    var allEvents: [TouchEvent] = []

    let eventStream: TouchEventStream
    let pointStream: TouchPathStream
    let strokeStream: PolylineStream
    @IBOutlet var debugView: DebugView!

    let savitzkyGolay = NaiveSavitzkyGolay()
    let douglasPeucker = NaiveDouglasPeucker()
    let pointDistance = NaivePointDistance()

    var settings: SettingsViewController?

    required init?(coder: NSCoder) {
        eventStream = TouchEventStream()
        pointStream = TouchPathStream()
        strokeStream = PolylineStream()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTable()

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

    private func setupTable() {
        let settings = SettingsViewController()
        self.settings = settings
        settings.delegate = self
        settings.savitzkyGolay = savitzkyGolay
        settings.douglasPeucker = douglasPeucker
        settings.pointDistance = pointDistance
        let nav = UINavigationController(rootViewController: settings)
        nav.navigationBar.barStyle = .default

        settings.navigationItem.title = "Settings"

        addChild(nav)
        nav.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nav.view)

        nav.view.widthAnchor.constraint(equalToConstant: 300).isActive = true
        nav.view.heightAnchor.constraint(equalToConstant: 300).isActive = true
        nav.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50).isActive = true
        nav.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
    }
}

extension ViewController: SettingsViewControllerDelegate {

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

    func didRequestExport() {
        let tmpDirURL = FileManager.default.temporaryDirectory.appendingPathComponent("events").appendingPathExtension("json")
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.withoutEscapingSlashes, .prettyPrinted]

        if let settings = settings,
           let json = try? jsonEncoder.encode(allEvents) {
            do {
                try json.write(to: tmpDirURL)

                let sharevc = UIActivityViewController(activityItems: [tmpDirURL], applicationActivities: nil)
                sharevc.popoverPresentationController?.barButtonItem = settings.navigationItem.rightBarButtonItem
                present(sharevc, animated: true, completion: nil)
            } catch {
                // ignore
            }
        }
    }
}
