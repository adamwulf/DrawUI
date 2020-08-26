//
//  ViewController.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 8/16/20.
//

import UIKit
import DrawUI
import QuickTableViewController

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
        let nav = UINavigationController(rootViewController: settings)
        nav.navigationBar.barStyle = .default

        let resmoothAndRedraw = { [weak self] in
            if let original = self?.debugView.originalStrokes,
               let smooth = self?.savitzkyGolay.smooth(strokes: original, deltas: []).strokes {
                self?.debugView.smoothStrokes = smooth
            }
            self?.debugView.setNeedsDisplay()
        }

        settings.tableView.contentInset = UIEdgeInsets(top: -40, left: 0, bottom: 0, right: 0)
        settings.navigationItem.title = "Settings"
        settings.tableContents = [
            Section(title: "Savitzky-Golay", rows: [
                SwitchRow(text: "Enabled", switchValue: savitzkyGolay.enabled, action: { [weak self] row in
                    guard let row = row as? SwitchRowCompatible else { return }
                    self?.savitzkyGolay.enabled = row.switchValue

                    if let original = self?.debugView.originalStrokes,
                       let smooth = self?.savitzkyGolay.smooth(strokes: original, deltas: []).strokes {
                        self?.debugView.smoothStrokes = smooth
                    }
                    self?.debugView.setNeedsDisplay()
                    settings.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
                }),
                SliderRow(text: "Window Size",
                          detailText: .value1(""),
                          value: (min: 1, max: 12, val: 1),
                          validate: { $0.rounded() },
                          customization: { [weak self] (cell, row) in
                            cell.detailTextLabel?.text = String(format: "%d", Int(row.sliderValue))
                            row.enabled = self?.savitzkyGolay.enabled ?? true
                          },
                          action: { [weak self] (row) in
                            let intVal = Int(row.sliderValue.rounded())
                            self?.savitzkyGolay.window = intVal

                            resmoothAndRedraw()
                          }),
                SliderRow(text: "Strength",
                          detailText: .value1(""),
                          value: (min: 0, max: 1, val: 1),
                          customization: { [weak self] (cell, row) in
                            cell.detailTextLabel?.text = String(format: "%d%%", Int((row.sliderValue * 100).rounded()))
                            row.enabled = self?.savitzkyGolay.enabled ?? true
                          },
                          action: { [weak self] (row) in
                            self?.savitzkyGolay.strength = CGFloat(row.sliderValue)

                            resmoothAndRedraw()
                          })
            ])
        ]

        addChild(nav)
        nav.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nav.view)

        nav.view.widthAnchor.constraint(equalToConstant: 300).isActive = true
        nav.view.heightAnchor.constraint(equalToConstant: 300).isActive = true
        nav.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50).isActive = true
        nav.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
    }
}
