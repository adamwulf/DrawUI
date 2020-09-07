//
//  EnabledSliderFormableRow.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 9/6/20.
//

import UIKit
import Former

class EnabledSliderRowFormer<T: UITableViewCell>: SliderRowFormer<T> where T: SliderFormableRow {
    open override func update() {
        super.update()
        cell.formSlider().tintAdjustmentMode = enabled ? .normal : .dimmed
    }
}
