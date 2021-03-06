//
//  Smoother.swift
//  DrawUI
//
//  Created by Adam Wulf on 3/19/21.
//

import Foundation

public protocol Smoother {
    func element(for line: Polyline, at elementIndex: Int) -> BezierStream.Element
    func maxIndex(for line: Polyline) -> Int
    func elementIndexes(for line: Polyline, at lineIndexes: IndexSet) -> IndexSet
    func elementIndexes(for line: Polyline, at lineIndex: Int) -> IndexSet
}
