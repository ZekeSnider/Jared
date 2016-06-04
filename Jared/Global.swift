//
//  Global.swift
//  Jared
//
//  Created by Zeke Snider on 6/4/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Foundation

extension CollectionType {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
