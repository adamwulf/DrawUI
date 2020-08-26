//
//  SliderRowCompatible.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 8/22/20.
//

import UIKit
import QuickTableViewController

/// This protocol defines the compatible interface of a `SwitchRow` regardless of its associated cell type.
public protocol SliderRowCompatible: Row, RowStyle {
    /// The state of the switch.
    var validate: ((Float) -> Float)? { get }
    var sliderValue: Float { get set }
    var sliderMin: Float { get }
    var sliderMax: Float { get }
    var enabled: Bool { get set }
}
