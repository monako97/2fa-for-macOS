//
//  CancelAll.swift
//  Auth2FA
//
//  Created by neko Mo on 2023/1/15.
//

import Combine

typealias CancelAll = Set<AnyCancellable>

extension CancelAll {
  mutating func cancelAll() {
    forEach { $0.cancel() }
    removeAll()
  }
}
