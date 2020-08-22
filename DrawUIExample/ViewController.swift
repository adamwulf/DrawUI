//
//  ViewController.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 8/16/20.
//

import UIKit
import DrawUI

class ViewController: UIViewController {

    let eventStream: TouchEventStream
    let pointStream: TouchPointStream
    let strokeStream: StrokeStream
    let savitzkyGolay = SavitzkyGolay()
    @IBOutlet var debugView: DebugView!

    required init?(coder: NSCoder) {
        eventStream = TouchEventStream()
        pointStream = TouchPointStream()
        strokeStream = StrokeStream()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSliders()

        debugView.layer.borderWidth = 1
        debugView.layer.borderColor = UIColor.black.cgColor

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

    private func setupSliders() {

        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 1
        slider.maximumValue = 12
        slider.value = 1
        slider.addAction(UIAction(handler: { [weak self] (_) in
            let intVal = Int(slider.value.rounded())
            self?.savitzkyGolay.window = intVal
            slider.value = Float(intVal)

            if let original = self?.debugView.originalStrokes,
               let smooth = self?.savitzkyGolay.smooth(strokes: original, deltas: []).strokes {
                self?.debugView.smoothStrokes = smooth
            }
            self?.debugView.setNeedsDisplay()
        }), for: .valueChanged)
        view.addSubview(slider)

        slider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        slider.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        slider.widthAnchor.constraint(equalToConstant: 250).isActive = true

        let strenSlider = UISlider()
        strenSlider.translatesAutoresizingMaskIntoConstraints = false
        strenSlider.minimumValue = 0
        strenSlider.maximumValue = 1
        strenSlider.value = 1
        strenSlider.addAction(UIAction(handler: { [weak self] (_) in
            self?.savitzkyGolay.strength = CGFloat(strenSlider.value)

            if let original = self?.debugView.originalStrokes,
               let smooth = self?.savitzkyGolay.smooth(strokes: original, deltas: []).strokes {
                self?.debugView.smoothStrokes = smooth
            }
            self?.debugView.setNeedsDisplay()
        }), for: .valueChanged)
        view.addSubview(strenSlider)

        strenSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 400).isActive = true
        strenSlider.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        strenSlider.widthAnchor.constraint(equalToConstant: 250).isActive = true
    }
}
