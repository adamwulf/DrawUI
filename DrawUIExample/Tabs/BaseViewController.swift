//
//  BaseViewController.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 3/14/21.
//

import UIKit
import DrawUI

class BaseViewController: UIViewController, UIDocumentPickerDelegate {

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

        let importButton = UIButton()
        importButton.setTitle("Import", for: .normal)
        importButton.setTitleColor(.systemBlue, for: .normal)
        view.addSubview(importButton)
        importButton.translatesAutoresizingMaskIntoConstraints = false
        importButton.topAnchor.constraint(equalTo: exportButton.bottomAnchor, constant: 20).isActive = true
        importButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        importButton.addTarget(self, action: #selector(didRequestImport), for: .touchUpInside)
    }

    // MARK: - UIDocumentPickerDelegate

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            guard let data = try? Data(contentsOf: url) else { continue }
            let decoder = JSONDecoder()
            guard let events = try? decoder.decode(Array<TouchEvent>.self, from: data) else { continue }
            importEvents(events)
        }
    }

    func importEvents(_ events: [TouchEvent]) {
        allEvents += events
        touchEventStream.process(events: events)
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

    @objc func didRequestImport(_ sender: UIView) {
        let picker = UIDocumentPickerViewController(documentTypes: ["public.json", "public.text"], in: .import)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
}
