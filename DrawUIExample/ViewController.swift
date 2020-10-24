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

    let eventStream: TouchEventStream
    let pointStream: TouchPointStream
    let strokeStream: StrokeStream
    @IBOutlet var debugView: DebugView!

    let savitzkyGolay = SavitzkyGolay()
    let douglasPeucker = DouglasPeucker()
    let pointDistance = PointDistance()

    required init?(coder: NSCoder) {
        eventStream = TouchEventStream()
        pointStream = TouchPointStream()
        strokeStream = StrokeStream()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTable()

        eventStream.eventStreamChanged = { [weak self] (updatedEvents) in
            guard let self = self else { return }
            let pointOutput = self.pointStream.process(touchEvents: updatedEvents)
            let strokeOutput = self.strokeStream.process(input: pointOutput)
            let douglasPeuckerOutput = self.douglasPeucker.process(input: strokeOutput)
            let pointDistanceOutput = self.pointDistance.process(input: douglasPeuckerOutput)
            let smoothOutput = self.savitzkyGolay.process(input: pointDistanceOutput)

            self.debugView?.originalStrokes = strokeOutput.strokes
            self.debugView?.smoothStrokes = smoothOutput.strokes
            self.debugView?.add(deltas: strokeOutput.deltas)
            self.debugView?.setNeedsDisplay()
        }

        debugView?.addGestureRecognizer(eventStream.gesture)
    }

    private func setupTable() {
        let settings = SettingsViewController()
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
        let originalOutput: StrokeStream.Output = (strokes: strokeStream.strokes, deltas: [])
        let douglasPeuckerOutput = self.douglasPeucker.process(input: originalOutput)
        let pointDistanceOutput = self.pointDistance.process(input: douglasPeuckerOutput)
        let smoothOutput = self.savitzkyGolay.process(input: pointDistanceOutput)
        debugView.smoothStrokes = smoothOutput.strokes
        debugView.setNeedsDisplay()
    }

    func didChangeSettings() {
        resmoothEverything()
    }
}
