//
//  Translation.swift
//  Auth2FA
//
//  Created by neko Mo on 2023/1/5.
//

import Foundation
import SwiftUI

enum Translation: CaseIterable {
    typealias RawValue = String
    
    
    static var light: LocalizedStringKey {
        return "Light"
    }
    static var dark: LocalizedStringKey {
        return "Dark"
    }
    static var auto: LocalizedStringKey {
        return "Auto"
    }
}

