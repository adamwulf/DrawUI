//
//  SliderRow.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 8/22/20.
//

import UIKit
import QuickTableViewController

/// A class that represents a row with a slider.
open class SliderRow<T: SliderCell>: SliderRowCompatible, Equatable, SliderCellDelegate {

  // MARK: - Initializer

  /// Initializes a `SliderRow` with a title, a slider state and an action closure.
  /// The detail text, icon and the customization closure are optional.
  public init(
    text: String,
    detailText: DetailText? = nil,
    sliderValue: Float,
    icon: Icon? = nil,
    customization: ((UITableViewCell, Row & RowStyle) -> Void)? = nil,
    action: ((Row) -> Void)?
  ) {
    self.text = text
    self.detailText = detailText
    self.sliderValue = sliderValue
    self.icon = icon
    self.action = action
    self.customize = { [weak self] (cell, row) in
        guard let cell = cell as? SliderCell else { return }
        cell.delegate = self
        customization?(cell, row)
    }
  }

  // MARK: - SliderRowCompatible

  /// The state of the slider.
  public var sliderValue: Float = 0 {
    didSet {
      guard sliderValue != oldValue else {
        return
      }
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

  #if os(iOS)

  /// The default accessory type is `.none`.
  public let accessoryType: UITableViewCell.AccessoryType = .none

  /// The `SliderRow` should not be selectable.
  public let isSelectable: Bool = false

  #elseif os(tvOS)

  /// Returns `.checkmark` when the `SliderValue` is on, otherwise returns `.none`.
  public var accessoryType: UITableViewCell.AccessoryType {
    return .none
  }

  /// The `SliderRow` is selectable on tvOS.
  public let isSelectable: Bool = true

  #endif

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

    // MARK: - SliderCellDelegate

    open func sliderCell(_ cell: SliderCell, didUpdateSlider value: Float) {

    }
}
