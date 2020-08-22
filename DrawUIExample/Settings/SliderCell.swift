//
//  SliderCell.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 8/22/20.
//

import UIKit
import QuickTableViewController

/// The `SliderCellDelegate` protocol allows the adopting delegate to respond to the UI interaction. Not available on tvOS.
@available(tvOS, unavailable, message: "SliderCellDelegate is not available on tvOS.")
public protocol SliderCellDelegate: class {
  /// Tells the delegate that the Slider control is toggled.
  func sliderCell(_ cell: SliderCell, didUpdateSlider value: Float)
}

/// A `UITableViewCell` subclass that shows a `UISlider` as the `accessoryView`.
open class SliderCell: UITableViewCell, Configurable {

  #if os(iOS)

  /// A `UISlider` as the `accessoryView`. Not available on tvOS.
  @available(tvOS, unavailable, message: "sliderControl is not available on tvOS.")
  public private(set) lazy var sliderControl: UISlider = {
    let control = UISlider()
    control.addTarget(self, action: #selector(SliderCell.didUpdateSlider(_:)), for: .valueChanged)
    return control
  }()

  #endif

  /// The slider cell's delegate object, which should conform to `SliderCellDelegate`. Not available on tvOS.
  @available(tvOS, unavailable, message: "SliderCellDelegate is not available on tvOS.")
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

  /// Set up the slider control (iOS) or accessory type (tvOS) with the provided row.
  open func configure(with row: Row & RowStyle) {
    #if os(iOS)
      if let row = row as? SliderRowCompatible {
        sliderControl.value = row.sliderValue
      }
      accessoryView = sliderControl
    #elseif os(tvOS)
      accessoryView = nil
      accessoryType = row.accessoryType
    #endif
  }

  // MARK: - Private

  @available(tvOS, unavailable, message: "UISlider is not available on tvOS.")
  @objc
  private func didUpdateSlider(_ sender: UISlider) {
    delegate?.sliderCell(self, didUpdateSlider: sender.value)
  }

  private func setUpAppearance() {
    textLabel?.numberOfLines = 0
    detailTextLabel?.numberOfLines = 0
  }

}
