//
//  ViewController.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 6/28/20.
//

import UIKit
import DrawUI

public class ViewController: UIViewController {

    let kScale: CGFloat = 4

    @IBOutlet var drawView: UIView!
    @IBOutlet var rendererControl: UISegmentedControl!
    @IBOutlet var scaleControl: UISegmentedControl!
    @IBOutlet var dynamicWidthSwitch: UISwitch!
    @IBOutlet var cachedEraserLabel: UILabel!
    @IBOutlet var cachedEraserSwitch: UISwitch!

    var observer: NSKeyValueObservation!
    var drawModel: DrawModel {
        didSet {
            for var renderer in allRenderers {
                renderer.drawModel = drawModel
            }

            refreshGestureFor(model: drawModel)
        }
    }
    var tool: Pen
    var allRenderers: [DrawViewRenderer]
    var currentRenderer: DrawViewRenderer

    var touchGesture: TouchStreamGestureRecognizer!

    @IBOutlet var widthConstraint: NSLayoutConstraint!
    @IBOutlet var heightConstraint: NSLayoutConstraint!

    var widthConstraint2: NSLayoutConstraint!
    var heightConstraint2: NSLayoutConstraint!

    required init?(coder: NSCoder) {
        drawModel = DrawModel()
        tool = Pen(minSize: 2, maxSize: 7, color: UIColor.black)

        let thumbRenderer = ThumbnailRenderer(model: drawModel)
        allRenderers = [thumbRenderer]
        currentRenderer = thumbRenderer

        super.init(coder: coder)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.addGestureRecognizer(TouchVelocityGestureRecognizer.sharedInstance)

        guard
            let wFirstItem = widthConstraint.firstItem,
            let wSecondItem = widthConstraint.secondItem,
            let hFirstItem = heightConstraint.firstItem,
            let hSecondItem = heightConstraint.secondItem
            else
        {
            return
        }

        widthConstraint2 = NSLayoutConstraint(item: wFirstItem,
                                              attribute: widthConstraint.firstAttribute,
                                              relatedBy: widthConstraint.relation,
                                              toItem: wSecondItem,
                                              attribute: widthConstraint.secondAttribute,
                                              multiplier: kScale,
                                              constant: 0)
        heightConstraint2 = NSLayoutConstraint(item: hFirstItem,
                                               attribute: heightConstraint.firstAttribute,
                                               relatedBy: heightConstraint.relation,
                                               toItem: hSecondItem,
                                               attribute: heightConstraint.secondAttribute,
                                               multiplier: kScale,
                                               constant: 0)

        touchGesture = TouchStreamGestureRecognizer(touchStream: drawModel.touchStream,
                                                    target: self,
                                                    action: #selector(touchStream(gesture:)))

        drawView.addGestureRecognizer(touchGesture)

        observer = drawView.observe(\.bounds) { [weak self] (_, _) in
            guard let self = self else { return }
            for renderer in self.allRenderers {
                renderer.drawModelDidUpdate(bounds: self.drawView.bounds)
            }
        }
    }

}

// MARK: - Refresh Renderers
extension ViewController {
    func refreshGestureFor(model: DrawModel) {
        drawView.removeGestureRecognizer(touchGesture)

        touchGesture = TouchStreamGestureRecognizer(touchStream: drawModel.touchStream,
                                                    target: self,
                                                    action: #selector(touchStream(gesture:)))

        drawView.addGestureRecognizer(touchGesture)
    }
}

// MARK: - Gestures
extension ViewController {
    @objc func touchStream(gesture: TouchStreamGestureRecognizer) {
        guard gesture.state == .ended else { return }

        drawModel.processTouchStream(with: tool)

        for renderer in allRenderers {
            renderer.update(with: drawModel, bounds: self.drawView.bounds)
        }
    }
}

// MARK: - Actions
extension ViewController {
    @IBAction func saveDrawing(_ button: UIButton) {
        let localDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let drawingURL = localDirectoryURL.appendingPathComponent("drawing.dat")

        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: drawModel, requiringSecureCoding: true)
            try data.write(to: drawingURL)

            let alert = UIAlertController(title: "Saved!", message: "The drawing is saved", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } catch {
            let alert = UIAlertController(title: "Error Saving Data", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func loadDrawing(_ button: UIButton) {
        // TODO: load from Documents folder
    }
    @IBAction func clearDrawing(_ button: UIButton) {
        drawModel = DrawModel()
    }
    @IBAction func changeTool(_ picker: UISegmentedControl) {
        if picker.selectedSegmentIndex == 0 {
            tool = Pen(minSize: 2, maxSize: 7, color: UIColor.black)
        } else {
            tool = Pen(minSize: 20, maxSize: 20, color: nil)
        }
    }
    @IBAction func didChangeRenderer(_ picker: UISegmentedControl) {
        guard picker.selectedSegmentIndex >= 0 && picker.selectedSegmentIndex <= 4 else { return }

        currentRenderer.invalidate()
        allRenderers = allRenderers.filter({ $0 as AnyObject !== currentRenderer as AnyObject })

        if picker.selectedSegmentIndex == 0 {
            currentRenderer = CALayerRenderer(view: drawView)
        } else if picker.selectedSegmentIndex == 1 {
            currentRenderer = CATiledLayerRenderer(view: drawView)
        } else if picker.selectedSegmentIndex == 2 {
            currentRenderer = NaiveDrawRectRenderer(view: drawView)
        } else if picker.selectedSegmentIndex == 3 {
            currentRenderer = SmartDrawRectRenderer(view: drawView)
        } else if picker.selectedSegmentIndex == 4 {
            currentRenderer = DebugRenderer(view: drawView)
        }

        allRenderers.append(currentRenderer)

        for var renderer in allRenderers {
            renderer.dynamicWidth = dynamicWidthSwitch.isOn

            if var renderer = renderer as? CanCacheEraser {
                cachedEraserLabel.isHidden = false
                cachedEraserSwitch.isHidden = false
                renderer.useCachedEraserLayerType = cachedEraserSwitch.isOn
            } else {
                cachedEraserLabel.isHidden = true
                cachedEraserSwitch.isHidden = true
            }
        }

        currentRenderer.drawModel = drawModel
    }
    @IBAction func didChangeScale(_ picker: UIResponder) {
        if scaleControl.selectedSegmentIndex == 1 {
            widthConstraint.isActive = false
            heightConstraint.isActive = false
            widthConstraint2.isActive = true
            heightConstraint2.isActive = true
        } else {
            widthConstraint.isActive = true
            heightConstraint.isActive = true
            widthConstraint2.isActive = false
            heightConstraint2.isActive = false
        }

        if scaleControl.selectedSegmentIndex == 2 {
            drawView.transform = .init(scaleX: kScale, y: kScale)
        } else {
            drawView.transform = .identity
        }
    }
    @IBAction func redraw(_ sender: UIResponder) {
        if let drawModel = drawModel.copy() as? DrawModel {
            self.drawModel = drawModel
        }
    }
    @IBAction func didChangeDynamicWidth(_ sender: UIResponder) {
        didChangeRenderer(rendererControl)
    }
    @IBAction func didChangeCachedEraser(_ sender: UIResponder) {
        didChangeRenderer(rendererControl)
    }
}
