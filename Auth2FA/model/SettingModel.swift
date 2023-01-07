//
//  SettingModel.swift
//  Auth2FA
//
//  Created by neko Mo on 2023/1/1.
//

import SwiftUI

enum SettingViewTab: String, CaseIterable {
    case general, theme
}
enum AppColorScheme: String, CaseIterable {
    case dark, light, unspecified
}
enum StatusMenu: String, CaseIterable {
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
class SettingModel: ObservableObject {
    let statusMenuType: [TabObject<StatusMenu>] = [
        TabObject(label: "Popover", key: .popover, icon: "bubble.middle.top", activeIcon: "bubble.middle.top.fill"),
        TabObject(label: "MenuBarExtra", key: .menuBarExtra, icon: "menubar.arrow.down.rectangle", activeIcon: "menubar.dock.rectangle"),
        TabObject(label: "Window", key: .window, icon: "macwindow")
    ]
    let themes: [TabObject<AppColorScheme>] = [
        TabObject(label: "Light", key: .light, icon: "sun.min", activeIcon: "sun.min.fill"),
        TabObject(label: "Dark", key: .dark, icon: "moon.stars", activeIcon: "moon.stars.fill"),
        TabObject(label: "Auto", key: .unspecified, icon: "apple.logo")
    ]
    let locales: [TabObject<Localication>] = [
        TabObject(label: "zh_Hans", key: .zh_Hans, icon: "character.bubble.zh", activeIcon: "character.bubble.fill.zh"),
        TabObject(label: "en", key: .en, icon: "character.bubble", activeIcon: "character.bubble.fill"),
        TabObject(label: "Auto", key: .unspecified, icon: "character.bubble", activeIcon: "character.bubble.fill")
    ]
    
    @AppStorage("locale") var locale: Localication = .unspecified
    @AppStorage("showMenuBarExtra") var showMenuBarExtra: Bool = false
    @AppStorage("statusMenu") var statusMenu: StatusMenu = .popover {
        didSet {
            self.showMenuBarExtra = statusMenu == .menuBarExtra
        }
    }
    @AppStorage("radius") var radius = 8.0
    @AppStorage("enableDelete") var enableDelete = true
    @AppStorage("showTimeRemaining") var showTimeRemaining = true
    @AppStorage("enableClipBoard") var enableClipBoard = true
    @AppStorage("enableShowQRCode") var enableShowQRCode = true
    @AppStorage("enableEdit") var enableEdit = true
    @AppStorage("showCode") var showCode = true
    @AppStorage("settingViewActiveTab") var activeTab: SettingViewTab = .general
    @AppStorage("theme") var theme: AppColorScheme = .unspecified
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
