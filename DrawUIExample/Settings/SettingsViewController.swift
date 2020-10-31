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
    func didRequestExport()
}

class SettingsViewController: FormViewController {

    var savitzkyGolay: NaiveSavitzkyGolay?
    var douglasPeucker: NaiveDouglasPeucker?
    var pointDistance: NaivePointDistance?
    var delegate: SettingsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let exportButton = UIBarButtonItem(systemItem: .action)
        exportButton.target = self
        exportButton.action = #selector(didRequestExport)
        navigationItem.rightBarButtonItem = exportButton

        let predictionRow = SwitchRowFormer<FormSwitchCell> {
            $0.titleLabel.text = "Allow Prediction"
        }.configure { _ in
            // noop
        }.onSwitchChanged { _ in
            // TODO: implement prediction toggle
            assertionFailure("To be implemented")
        }

        let touchTypeRow = SegmentedRowFormer<FormSegmentedCell> {
            $0.titleLabel.text = "Events"
        }.onSegmentSelected { _, _ in
            // noop
        }.configure { (row) in
            row.segmentTitles = ["Touch", "Pencil", "Both"]
            row.selectedIndex = 2
        }

        let section = SectionFormer(rowFormer: predictionRow, touchTypeRow)
            .set(headerViewFormer: LabelViewFormer<FormLabelHeaderView>().configure { (view) in
                view.text = "Touch Events"
            })
        former.append(sectionFormer: section)

        let savitzkyGolayRow = LabelRowFormer<FormLabelCell>()
            .configure { row in
                row.text = "Savitzky-Golay"
            }.onSelected { [weak self] _ in
                guard let self = self else { return }
                let settings = SavitzkyGolayViewController()
                settings.savitzkyGolay = self.savitzkyGolay
                settings.delegate = self
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
                settings.delegate = self
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
                settings.pointDistance = self.pointDistance
                settings.delegate = self
                self.navigationController?.pushViewController(settings, animated: true)
            }.onUpdate { (row) in
                guard let pointDinstance = self.pointDistance else { return }
                if pointDinstance.enabled {
                    row.subText = "Enabled"
                } else {
                    row.subText = "Disabled"
                }
            }

        let smoothingSection = SectionFormer(rowFormer: savitzkyGolayRow, douglasPeuckerRow, pointDinstanceRow)
            .set(headerViewFormer: LabelViewFormer<FormLabelHeaderView>().configure { (view) in
                view.text = "Smoothing"
            })
        former.append(sectionFormer: smoothingSection)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.former.reload()
        tableView.reloadData()
    }

    @objc func didRequestExport() {
        delegate?.didRequestExport()
    }
}

extension SettingsViewController: SettingsViewControllerDelegate {
    func didChangeSettings() {
        delegate?.didChangeSettings()
    }
}
