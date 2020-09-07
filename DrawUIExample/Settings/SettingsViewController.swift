//
//  SettingsViewController.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 8/23/20.
//

import UIKit
import Former
import DrawUI

protocol SettingsViewControllerDelegate: class {
    func didChange(savitzkyGolay: SavitzkyGolay)
}

class SettingsViewController: FormViewController {

    var savitzkyGolay: SavitzkyGolay?
    var delegate: SettingsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let windowSliderRow = SliderRowFormer<FormSliderCell> {
            $0.titleLabel.text = "Window"
            $0.formSlider().minimumValue = 2
            $0.formSlider().maximumValue = 12
        }.configure { (row) in
            guard let savitzkyGolay = savitzkyGolay else { return }
            row.value = Float(savitzkyGolay.window)
        }.adjustedValueFromValue { (value) -> Float in
            guard let savitzkyGolay = self.savitzkyGolay else { return value }
            savitzkyGolay.window = Int(value.rounded())
            self.delegate?.didChange(savitzkyGolay: savitzkyGolay)
            return Float(savitzkyGolay.window)
        }.displayTextFromValue { (value) -> String in
            return "\(Int(value))"
        }
        let strengthSliderRow = SliderRowFormer<FormSliderCell> {
            $0.titleLabel.text = "Strength"
            $0.formSlider().minimumValue = 0
            $0.formSlider().maximumValue = 1
        }.configure { (row) in
            guard let savitzkyGolay = savitzkyGolay else { return }
            row.value = Float(savitzkyGolay.strength)
        }.adjustedValueFromValue { (value) -> Float in
            guard let savitzkyGolay = self.savitzkyGolay else { return value }
            savitzkyGolay.strength = CGFloat(value)
            self.delegate?.didChange(savitzkyGolay: savitzkyGolay)
            return Float(savitzkyGolay.strength)
        }.displayTextFromValue { (value) -> String in
            return "\(Int((value * 100).rounded()))%"
        }

        let header = LabelViewFormer<FormLabelHeaderView>().configure { (view) in
            view.text = "Savitzky-Golay"
        }
        let section = SectionFormer(rowFormer: windowSliderRow, strengthSliderRow)
            .set(headerViewFormer: header)
        former.append(sectionFormer: section)
    }
}
