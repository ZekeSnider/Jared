//
//  Global.swift
//  Jared
//
//  Created by Zeke Snider on 6/4/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}

public func NSLocalizedString(_ key: String) -> String {
    return Bundle(for: InternalModule.self).localizedString(forKey: key, value: nil, table: nil)
}
