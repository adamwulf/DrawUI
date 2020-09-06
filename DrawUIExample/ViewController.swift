//
//  ViewController.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 8/16/20.
//

import UIKit
import DrawUI
import XLForm

class ViewController: UIViewController {

    let eventStream: TouchEventStream
    let pointStream: TouchPointStream
    let strokeStream: StrokeStream
    @IBOutlet var debugView: DebugView!

    let savitzkyGolay = SavitzkyGolay()

    required init?(coder: NSCoder) {
        eventStream = TouchEventStream()
        pointStream = TouchPointStream()
        strokeStream = StrokeStream()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTable()

        eventStream.onChange = { [weak self] (eventStream) in
            guard let self = self else { return }
            let updatedEvents = eventStream.process()
            self.pointStream.add(touchEvents: updatedEvents)
        }
        pointStream.onChange = { [weak self] (strokes, deltas) in
            self?.strokeStream.add(touchEvents: deltas)
        }
        strokeStream.onChange = { [weak self] (strokes, deltas) in
            guard let self = self else { return }
            self.debugView?.originalStrokes = strokes
            self.debugView?.smoothStrokes = self.savitzkyGolay.smooth(strokes: strokes, deltas: deltas).strokes
            self.debugView?.add(deltas: deltas)
            self.debugView?.setNeedsDisplay()
        }

        debugView?.addGestureRecognizer(eventStream.gesture)
    }

    private func setupTable() {
        let settings = SettingsViewController()
        settings.delegate = self
        settings.savitzkyGolay = savitzkyGolay
        let nav = UINavigationController(rootViewController: settings)
        nav.navigationBar.barStyle = .default

//        let savitzkyGolaySection = SavitzkyGolaySection(savitzkyGolay: savitzkyGolay, didToggleEnabled: { () in
//            resmoothEverything()
//            // The setting has also been enabled/disabled, so reload all of the rows to reflect their new state
//            settings.tableView.reloadSections(IndexSet(0 ..< settings.tableView.numberOfSections), with: .fade)
//        }, didChangeSettings: resmoothEverything)
//
//        settings.tableView.contentInset = UIEdgeInsets(top: -40, left: 0, bottom: 0, right: 0)
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

    func resmoothEverything() {
        // If any of the settings have changed or been reenabled, etc.
        let original = strokeStream.strokes
        let smooth = savitzkyGolay.smooth(strokes: original, deltas: []).strokes
        debugView.smoothStrokes = smooth
        debugView.setNeedsDisplay()
    }

    func didChange(savitzkyGolay: SavitzkyGolay) {
        resmoothEverything()
    }
}
