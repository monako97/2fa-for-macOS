//
//  SettingModel.swift
//  Auth2FA
//
//  Created by neko Mo on 2023/1/1.
//

import SwiftUI
import ServiceManagement

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
    @Published var autoStart: Int = SMAppService.mainApp.status.rawValue {
        didSet {
            registerStartupItem()
        }
    }
    func registerStartupItem() {
        do {
            if SMAppService.mainApp.status.rawValue == 1 {
                try SMAppService.mainApp.unregister()
            } else if SMAppService.mainApp.status.rawValue == 0 {
                try SMAppService.mainApp.register()
            }
        } catch {
            NSLog("设置启动项失败: \(error), \(error)")
        }
    }
}
