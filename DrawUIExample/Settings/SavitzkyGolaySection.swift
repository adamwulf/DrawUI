//
//  SavinSection.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 9/5/20.
//

import UIKit
import DrawUI
import QuickTableViewController

class SavitzkyGolaySection: Section {

    required init(savitzkyGolay: SavitzkyGolay, didToggleEnabled: (() -> Void)? = nil, didChangeSettings: (() -> Void)? = nil) {
        super.init(title: "Savitzky-Golay", rows: [
            SwitchRow(text: "Enabled", switchValue: savitzkyGolay.enabled, action: { row in
                guard let row = row as? SwitchRowCompatible else { return }
                savitzkyGolay.enabled = row.switchValue

                didToggleEnabled?()
            }),
            SliderRow(text: "Window Size",
                      detailText: .value1(""),
                      value: (min: 1, max: 12, val: 1),
                      validate: { $0.rounded() },
                      customization: { (cell, row) in
                        cell.detailTextLabel?.text = String(format: "%d", Int(row.sliderValue))
                        row.enabled = savitzkyGolay.enabled
                      },
                      action: { (row) in
                        let intVal = Int(row.sliderValue.rounded())
                        savitzkyGolay.window = intVal

                        didChangeSettings?()
                      }),
            SliderRow(text: "Strength",
                      detailText: .value1(""),
                      value: (min: 0, max: 1, val: 1),
                      customization: { (cell, row) in
                        cell.detailTextLabel?.text = String(format: "%d%%", Int((row.sliderValue * 100).rounded()))
                        row.enabled = savitzkyGolay.enabled
                      },
                      action: { (row) in
                        savitzkyGolay.strength = CGFloat(row.sliderValue)

                        didChangeSettings?()
                      })
        ])
    }
}
