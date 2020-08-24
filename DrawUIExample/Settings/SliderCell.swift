//
//  SliderCell.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 8/22/20.
//

import UIKit
import QuickTableViewController

public protocol SliderCellDelegate: class {
    /// Tells the delegate that the Slider control is toggled.
    func sliderCell(_ cell: SliderCell, didUpdateSlider value: Float)
}

/// A `UITableViewCell` subclass that shows a `UISlider` as the `accessoryView`.
open class SliderCell: UITableViewCell, Configurable {

    public private(set) lazy var sliderControl: UISlider = {
        let control = UISlider()
        control.addTarget(self, action: #selector(SliderCell.didUpdateSlider(_:)), for: .valueChanged)
        return control
    }()

    open weak var delegate: SliderCellDelegate?

    // MARK: - Initializer

    /**
     Overrides `UITableViewCell`'s designated initializer.

     - parameter style:           A constant indicating a cell style.
     - parameter reuseIdentifier: A string used to identify the cell object if it is to be reused for drawing multiple rows of a table view.

     - returns: An initialized `SliderCell` object.
     */
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpAppearance()
    }

    /**
     Overrides the designated initializer that returns an object initialized from data in a given unarchiver.

     - parameter aDecoder: An unarchiver object.

     - returns: `self`, initialized using the data in decoder.
     */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpAppearance()
    }

    // MARK: - Configurable

    /// Set up the slider control (iOS) with the provided row.
    open func configure(with row: Row & RowStyle) {
        if let row = row as? SliderRowCompatible {
            sliderControl.minimumValue = row.sliderMin
            sliderControl.maximumValue = row.sliderMax
            sliderControl.value = row.sliderValue
        }
        accessoryView = sliderControl
    }

    // MARK: - Private

    @objc private func didUpdateSlider(_ sender: UISlider) {
        delegate?.sliderCell(self, didUpdateSlider: sender.value)
    }

    private func setUpAppearance() {
        textLabel?.numberOfLines = 0
        detailTextLabel?.numberOfLines = 0
    }
}
