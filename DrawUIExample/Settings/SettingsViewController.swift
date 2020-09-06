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
        let labelRow = LabelRowFormer<FormLabelCell>()
            .configure { row in
                row.text = "Label Cell"
            }.onSelected { _ in
                // Do Something
            }
        let inlinePickerRow = InlinePickerRowFormer<FormInlinePickerCell, Int> {
            $0.titleLabel.text = "Inline Picker Cell"
        }.configure { row in
            row.pickerItems = (1...5).map {
                InlinePickerItem(title: "Option\($0)", value: Int($0))
            }
        }.onValueChanged { _ in
            // Do Something
        }
        let sliderRow = SliderRowFormer<FormSliderCell> {
            $0.titleLabel.text = "Inline Slider Cell"
            $0.formSlider().minimumValue = 1
            $0.formSlider().maximumValue = 12
        }.configure { (row) in
            guard let savitzkyGolay = savitzkyGolay else { return }
            row.value = Float(savitzkyGolay.window)
        }.adjustedValueFromValue { (value) -> Float in
            guard let savitzkyGolay = self.savitzkyGolay else { return value }
            savitzkyGolay.window = Int(value.rounded())
            return Float(savitzkyGolay.window)
        }
        let header = LabelViewFormer<FormLabelHeaderView> { view in
            view.titleLabel.text = "Label Header"
        }
        let section = SectionFormer(rowFormer: labelRow, inlinePickerRow, sliderRow)
            .set(headerViewFormer: header)
        former.append(sectionFormer: section)
    }
}
