//
//  Int.swift
//  Auth2FA
//
//  Created by neko Mo on 2023/1/6.
//

import Foundation

extension Int {
    /// Data from Int
    var data: Data {
        var int = self
        let intData = Data(bytes: &int, count: MemoryLayout.size(ofValue: self))
        return intData
    }
}
