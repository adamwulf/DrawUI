//
//  DouglasPeuckerViewController.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 9/6/20.
//

import UIKit
import Former
import DrawUI

class DouglasPeuckerViewController: FormViewController {

    var douglasPeucker: NaiveDouglasPeucker?
    var delegate: SettingsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Douglas-Peucker"

        let enabledRow = SwitchRowFormer<FormSwitchCell> {
            $0.titleLabel.text = "Enabled"
        }.configure { (row) in
            guard let douglasPeucker = douglasPeucker else { return }
            row.switched = douglasPeucker.enabled
        }.onSwitchChanged { (toggle) in
            guard let douglasPeucker = self.douglasPeucker else { return }
            douglasPeucker.enabled = toggle
            self.delegate?.didChangeSettings()
        }

        let section = SectionFormer(rowFormer: enabledRow)
        former.append(sectionFormer: section)
    }
}
