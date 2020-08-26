//
//  SettingsViewController.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 8/23/20.
//

import UIKit
import QuickTableViewController

class SettingsViewController: QuickTableViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        (cell as? SliderCell)?.delegate = self

        return cell
    }
}

#if os(iOS)
extension SettingsViewController: SliderCellDelegate {

    // MARK: - SliderCellDelegate

    open func sliderCell(_ cell: SliderCell, didUpdateSlider value: Float) {
        guard
            let indexPath = tableView.indexPath(for: cell),
            let row = tableContents[indexPath.section].rows[indexPath.row] as? SliderRowCompatible
        else {
            return
        }
        row.sliderValue = value
        // allow the row to validate the value (allows for rounding, snapping, etc)
        cell.sliderControl.value = row.sliderValue
        row.customize?(cell, row)
    }

}
#endif
