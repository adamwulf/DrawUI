//
//  BaseViewController.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 3/14/21.
//

import UIKit
import DrawUI

class BaseViewController: UIViewController {

    var allEvents: [TouchEvent] = []

    let touchEventStream = TouchEventStream()

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        touchEventStream.addConsumer { (updatedEvents) in
            self.allEvents.append(contentsOf: updatedEvents)
        }
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
    }
}

extension BaseViewController {

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
