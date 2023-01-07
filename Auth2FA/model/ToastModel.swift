//
//  ToastModel.swift
//  Auth2FA
//
//  Created by neko Mo on 2022/12/31.
//

import Foundation
import Combine

struct Toast: Identifiable {
    let id = UUID()
    let message: String
}

class ToastModel: ObservableObject {
    let toast: [Toast] = []
}
