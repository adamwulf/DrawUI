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
    var douglasPeucker: DouglasPeucker?
    var pointDinstance: PointDistance?
    var delegate: SettingsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let savitzkyGolayRow = LabelRowFormer<FormLabelCell>()
            .configure { row in
                row.text = "Savitzky-Golay"
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

        let douglasPeuckerRow = LabelRowFormer<FormLabelCell>()
            .configure { row in
                row.text = "Douglas-Peucker"
            }.onSelected { [weak self] _ in
                guard let self = self else { return }
                let settings = DouglasPeuckerViewController()
                settings.douglasPeucker = self.douglasPeucker
                self.navigationController?.pushViewController(settings, animated: true)
            }.onUpdate { (row) in
                guard let douglasPeucker = self.douglasPeucker else { return }
                if douglasPeucker.enabled {
                    row.subText = "Enabled"
                } else {
                    row.subText = "Disabled"
                }
            }

        let pointDinstanceRow = LabelRowFormer<FormLabelCell>()
            .configure { row in
                row.text = "Point Distance"
            }.onSelected { [weak self] _ in
                guard let self = self else { return }
                let settings = PointDinstanceViewController()
                settings.pointDistance = self.pointDinstance
                self.navigationController?.pushViewController(settings, animated: true)
            }.onUpdate { (row) in
                guard let pointDinstance = self.pointDinstance else { return }
                if pointDinstance.enabled {
                    row.subText = "Enabled"
                } else {
                    row.subText = "Disabled"
                }
            }

        let section = SectionFormer(rowFormer: savitzkyGolayRow, douglasPeuckerRow, pointDinstanceRow)
        former.append(sectionFormer: section)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.former.reload()
        tableView.reloadData()
    }
}
