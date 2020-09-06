//
//  SettingsViewController.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 8/23/20.
//

import UIKit
import XLForm
import DrawUI

protocol SettingsViewControllerDelegate {
    func didChange(savitzkyGolay: SavitzkyGolay)
}

class SettingsViewController: XLFormViewController {

    fileprivate struct Tags {
        static let Switch = "switch"
        static let Slider = "slider"
    }

    var delegate: SettingsViewControllerDelegate?
    var savitzkyGolay: SavitzkyGolay?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initializeForm()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeForm()
    }

    // MARK: Helpers

    func initializeForm() {
        let form: XLFormDescriptor
        var section: XLFormSectionDescriptor
        var row: XLFormRowDescriptor

        form = XLFormDescriptor(title: "Text Fields")
        form.assignFirstResponderOnShow = true

        section = XLFormSectionDescriptor.formSection(withTitle: "Other Cells")
        section.footerTitle = "OthersFormViewController.swift"
        form.addFormSection(section)

        section.addFormRow(XLFormRowDescriptor(tag: Tags.Switch, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "Switch"))

        row = XLFormRowDescriptor(tag: Tags.Slider, rowType: XLFormRowDescriptorTypeSlider, title: "Slider")
        row.value = 2
        row.cellConfigAtConfigure["slider.maximumValue"] = 12
        row.cellConfigAtConfigure["slider.minimumValue"] = 2
        row.cellConfigAtConfigure["steps"] = 10
        row.disabled = NSPredicate(format: "$\(Tags.Switch).value == 0")
        row.onChangeBlock = { [weak self] oldValue, newValue, _ in
            guard let newValue = newValue as? Int,
                  let self = self,
                  let savitzkyGolay = self.savitzkyGolay
            else { return }
            let message = "New value: \(newValue)"
            savitzkyGolay.window = newValue
            if let oldValue = oldValue as? Int,
               oldValue != newValue {
                row.value = savitzkyGolay.window
            }
            row.title = "Slider: \(savitzkyGolay.window)"
            print(message)
            self.delegate?.didChange(savitzkyGolay: savitzkyGolay)
        }
        section.addFormRow(row)

        self.form = form
    }
}
