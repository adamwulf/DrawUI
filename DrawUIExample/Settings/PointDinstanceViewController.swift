//
//  PointDinstanceViewController.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 9/6/20.
//

import UIKit
import Former
import DrawUI

class PointDinstanceViewController: FormViewController {

    var pointDistance: PointDistance?
    var delegate: SettingsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Point Distance"

        let enabledRow = SwitchRowFormer<FormSwitchCell> {
            $0.titleLabel.text = "Enabled"
        }.configure { (row) in
            guard let pointDistance = pointDistance else { return }
            row.switched = pointDistance.enabled
        }.onSwitchChanged { (toggle) in
            guard let pointDistance = self.pointDistance else { return }
            pointDistance.enabled = toggle
            self.delegate?.didChangeSettings()
        }

        let section = SectionFormer(rowFormer: enabledRow)
        former.append(sectionFormer: section)
    }
}
