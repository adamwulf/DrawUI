//
//  SettingsViewController.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 8/23/20.
//

import UIKit
import Former
import DrawUI

class SavitzkyGolayViewController: FormViewController {

    var savitzkyGolay: NaiveSavitzkyGolay?
    var delegate: SettingsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Savitzky-Golay"

        let windowSliderRow = EnabledSliderRowFormer<FormSliderCell> {
            $0.titleLabel.text = "Window"
            $0.formSlider().minimumValue = 2
            $0.formSlider().maximumValue = 12
        }.configure { (row) in
            guard let savitzkyGolay = savitzkyGolay else { return }
            row.value = Float(savitzkyGolay.window)
        }.adjustedValueFromValue { (value) -> Float in
            guard let savitzkyGolay = self.savitzkyGolay else { return value }
            savitzkyGolay.window = Int(value.rounded())
            return Float(savitzkyGolay.window)
        }.displayTextFromValue { (value) -> String in
            return "\(Int(value))"
        }.update { (row) in
            guard let savitzkyGolay = self.savitzkyGolay else { return }
            row.enabled = savitzkyGolay.enabled
        }.onValueChanged { _ in
            self.delegate?.didChangeSettings()
        }
        let strengthSliderRow = EnabledSliderRowFormer<FormSliderCell> {
            $0.titleLabel.text = "Strength"
            $0.formSlider().minimumValue = 0
            $0.formSlider().maximumValue = 1
        }.configure { (row) in
            guard let savitzkyGolay = savitzkyGolay else { return }
            row.value = Float(savitzkyGolay.strength)
        }.adjustedValueFromValue { (value) -> Float in
            guard let savitzkyGolay = self.savitzkyGolay else { return value }
            savitzkyGolay.strength = CGFloat(value)
            return Float(savitzkyGolay.strength)
        }.displayTextFromValue { (value) -> String in
            return "\(Int((value * 100).rounded()))%"
        }.update { (row) in
            guard let savitzkyGolay = self.savitzkyGolay else { return }
            row.enabled = savitzkyGolay.enabled
        }.onValueChanged { _ in
            self.delegate?.didChangeSettings()
        }

        let enabledRow = SwitchRowFormer<FormSwitchCell> {
            $0.titleLabel.text = "Enabled"
        }.configure { (row) in
            guard let savitzkyGolay = savitzkyGolay else { return }
            row.switched = savitzkyGolay.enabled
        }.onSwitchChanged { (toggle) in
            guard let savitzkyGolay = self.savitzkyGolay else { return }
            savitzkyGolay.enabled = toggle
            windowSliderRow.enabled = toggle
            strengthSliderRow.enabled = toggle
            self.delegate?.didChangeSettings()
        }

        let section = SectionFormer(rowFormer: enabledRow, windowSliderRow, strengthSliderRow)
        former.append(sectionFormer: section)
    }
}
