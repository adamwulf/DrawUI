//
//  SettingsViewController.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 9/6/20.
//

import UIKit
import Former
import DrawUI

protocol SettingsViewControllerDelegate: class {
    func didChangeSettings()
}

class SettingsViewController: FormViewController {

    var savitzkyGolay: SavitzkyGolay?
    var delegate: SettingsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let savitzkyGolayRow = LabelRowFormer<FormLabelCell>()
            .configure { row in
                row.text = "Savitzky Golay"
            }.onSelected { [weak self] _ in
                guard let self = self else { return }
                let settings = SavitzkyGolayViewController()
                settings.savitzkyGolay = self.savitzkyGolay
                self.navigationController?.pushViewController(settings, animated: true)
            }.onUpdate { (row) in
                guard let savitzkyGolay = self.savitzkyGolay else { return }
                if savitzkyGolay.enabled {
                    row.subText = "W: \(savitzkyGolay.window), S: \(Int((savitzkyGolay.strength * 100).rounded()))%"
                } else {
                    row.subText = "Disabled"
                }
            }

        let section = SectionFormer(rowFormer: savitzkyGolayRow)
        former.append(sectionFormer: section)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.former.reload()
        tableView.reloadData()
    }
}
