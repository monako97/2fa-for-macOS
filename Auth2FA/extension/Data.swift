//
//  Data.swift
//  Auth2FA
//
//  Created by neko Mo on 2023/1/6.
//

import Foundation

extension Data {
    /// The data represented as a byte array
    public var bytes: Array<UInt8> {
        return Array(self)
    }

    public init(hex: String) {
        self.init(Array<UInt8>(hex: hex))
    }
}
