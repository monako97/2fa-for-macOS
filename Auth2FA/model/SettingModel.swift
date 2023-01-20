//
//  SettingModel.swift
//  Auth2FA
//
//  Created by neko Mo on 2023/1/1.
//

import SwiftUI

enum AppColorScheme: String, CaseIterable {
    case dark, light, unspecified
}
enum SceneMode: String, CaseIterable {
    case popover, menuBarExtra, window
}
enum Localication: String, CaseIterable {
    case zh_Hans = "zh-Hans", en = "en", unspecified = "unspecified"
}
func getDefaultLang() -> Localication {
    if Locale.current.language.languageCode != nil {
        if Locale.current.language.languageCode == "zh" {
            return .zh_Hans
        }
        return .en
    }
    return .en
}
func getLocale(locale: Localication) -> String {
    if locale.rawValue == "unspecified" {
        return getDefaultLang().rawValue
    }
    return locale.rawValue
}

func getColorSchema(theme: AppColorScheme) -> ColorScheme? {
    switch theme {
        case .dark:
            return .dark
        case .light:
            return.light
        default:
            return nil
    }
}

let sceneModes: [TabObject<SceneMode>] = [
    TabObject("popover", .popover, "bubble.middle.top", "bubble.middle.top.fill"),
    TabObject("menuBarExtra", .menuBarExtra, "menubar.arrow.down.rectangle", "menubar.dock.rectangle"),
    TabObject("window", .window, "macwindow")
]
let themes: [TabObject<AppColorScheme>] = [
    TabObject("light", .light, "sun.min", "sun.min.fill"),
    TabObject("dark", .dark, "moon.stars", "moon.stars.fill"),
    TabObject("auto", .unspecified, "apple.logo")
]
let locales: [TabObject<Localication>] = [
    TabObject("zh_Hans", .zh_Hans, "textformat.size.zh"),
    TabObject("en", .en, "textformat"),
    TabObject("auto", .unspecified, "textformat.size")
]
final class SettingModel: NSObject, ObservableObject {
    @AppStorage("locale") var locale: Localication = .unspecified
    @AppStorage("showMenuBarExtra") var showMenuBarExtra: Bool = false
    @AppStorage("sceneMode") var sceneMode: SceneMode = .popover {
        didSet {
            self.showMenuBarExtra = sceneMode == .menuBarExtra
        }
    }
    @AppStorage("radius") var radius = 8.0
    @AppStorage("enableDelete") var enableDelete = true
    @AppStorage("showTimeRemaining") var showTimeRemaining = true
    @AppStorage("enableClipBoard") var enableClipBoard = true
    @AppStorage("enableShowQRCode") var enableShowQRCode = true
    @AppStorage("enableEdit") var enableEdit = true
    @AppStorage("showCode") var showCode = true
    @AppStorage("theme") var theme: AppColorScheme = .unspecified
}
