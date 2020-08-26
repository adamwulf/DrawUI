//
//  SliderRow.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 8/22/20.
//
// swiftlint:disable large_tuple

import UIKit
import QuickTableViewController

/// A class that represents a row with a slider.
open class SliderRow<T: SliderCell>: SliderRowCompatible, Equatable {

    // MARK: - Initializer

    /// Initializes a `SliderRow` with a title, a slider state and an action closure.
    /// The detail text, icon and the customization closure are optional.
    public init(
        text: String,
        detailText: DetailText? = nil,
        value: (min: Float, max: Float, val: Float) = (0, 1, 1),
        icon: Icon? = nil,
        validate: ((Float) -> Float)? = nil,
        customization: ((SliderCell, SliderRowCompatible) -> Void)? = nil,
        action: ((SliderRowCompatible) -> Void)?
    ) {
        self.text = text
        self.detailText = detailText
        self.sliderMin = value.min
        self.sliderMax = value.max
        self.icon = icon
        self.validate = validate
        self.action = { (row: Row) in
            guard let row = row as? SliderRowCompatible else { return }
            action?(row)
        }
        self.customize = { (cell, row) in
            guard
                let row = row as? SliderRowCompatible,
                let cell = cell as? SliderCell
            else {
                return
            }
            customization?(cell, row)
            cell.enabled = row.enabled
        }
        self.value = value.val
    }

    // MARK: - SliderRowCompatible

    public var validate: ((Float) -> Float)?
    public var sliderMin: Float
    public var sliderMax: Float
    public var enabled: Bool = true

    /// The state of the slider.
    private var value: Float = 0
    public var sliderValue: Float {
        get {
            value
        }
        set {
            let validated = validate?(newValue) ?? newValue
            guard value != validated else { return }
            value = validated
            DispatchQueue.main.async {
                self.action?(self)
            }
        }
    }

    // MARK: - Row

    /// The text of the row.
    public let text: String

    /// The detail text of the row.
    public let detailText: DetailText?

    /// A closure that will be invoked when the `sliderValue` is changed.
    public let action: ((Row) -> Void)?

    // MARK: - RowStyle

    /// The type of the table view cell to display the row.
    public let cellType: UITableViewCell.Type = T.self

    /// Returns the reuse identifier of the table view cell to display the row.
    public var cellReuseIdentifier: String {
        return "SliderCell"
    }

    /// Returns the table view cell style for the specified detail text.
    public var cellStyle: UITableViewCell.CellStyle {
        return detailText?.style ?? .default
    }

    /// The icon of the row.
    public let icon: Icon?

    /// The default accessory type is `.none`.
    public let accessoryType: UITableViewCell.AccessoryType = .none

    /// The `SliderRow` should not be selectable.
    public let isSelectable: Bool = false

    /// The additional customization during cell configuration.
    public let customize: ((UITableViewCell, Row & RowStyle) -> Void)?

    // MARK: - Equatable

    /// Returns true iff `lhs` and `rhs` have equal titles, detail texts, slider values, and icons.
    public static func == (lhs: SliderRow, rhs: SliderRow) -> Bool {
        return
            lhs.text == rhs.text &&
            lhs.detailText == rhs.detailText &&
            lhs.sliderValue == rhs.sliderValue &&
            lhs.icon == rhs.icon
    }
}
