//
//  StrokeFilter.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/18/20.
//

import Foundation

// Also, some future smoothing algorithm ideas:
// https://en.wikipedia.org/wiki/Smoothing

public protocol StrokeFilter {
    var enabled: Bool { get set }
    func process(input: StrokeStream.Output) -> StrokeStream.Output
}
