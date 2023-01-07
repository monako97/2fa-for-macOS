//
//  Localication.swift
//  Auth2FA
//
//  Created by neko Mo on 2023/1/5.
//

import Foundation

enum Localication: String, CaseIterable, Identifiable {
    case zh_Hans = "zh-Hans"
    case en = "en"
    var id: String { self.rawValue }
}

enum LocaleStrings: String, CaseIterable, Identifiable {
    case zh_Hans = "中文"
    case en = "English"
    var id: String { self.rawValue }
}

extension LocaleStrings {
    var suggestedLocalication: Localication {
        switch self {
            case .zh_Hans: return .zh_Hans
            case .en: return .en
        }
    }
}

class LocalicationModel: ObservableObject {
    @Published var localeString: Localication = .zh_Hans
}

