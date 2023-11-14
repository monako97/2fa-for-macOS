//
//  SettingsView.swift
//  Auth2FA
//
//  Created by neko Mo on 2023/1/1.
//

import SwiftUI
import ServiceManagement
import SafariServices

struct SettingsView: View {
    @EnvironmentObject var setting: SettingModel
    private let toggle = [TabObject("off", false),TabObject("on", true)]
    private let sceneModes: [TabObject<SceneMode>] = [
        TabObject("popover", .popover, "bubble.middle.top", "bubble.middle.top.fill"),
        TabObject("menuBarExtra", .menuBarExtra, "menubar.arrow.down.rectangle", "menubar.dock.rectangle"),
        TabObject("window", .window, "macwindow")
    ]
    private let themes: [TabObject<AppColorScheme>] = [
        TabObject("light", .light, "sun.min", "sun.min.fill"),
        TabObject("dark", .dark, "moon.stars", "moon.stars.fill"),
        TabObject("auto", .unspecified, "apple.logo")
    ]
    private let locales: [TabObject<Localication>] = [
        TabObject("zh_Hans", .zh_Hans, "textformat.size.zh"),
        TabObject("en", .en, "textformat"),
        TabObject("auto", .unspecified, "textformat.size")
    ]
    private let autoStart = [TabObject("off", SMAppService.Status.notRegistered),TabObject("on", SMAppService.Status.enabled)]
    var body: some View {
        Form {
            Group {
                LabeledContent("language"){
                    SegmentedControlView(locales, $setting.locale)
                }
                LabeledContent("view"){
                    SegmentedControlView(sceneModes, $setting.sceneMode)
                }
                LabeledContent("theme"){
                    SegmentedControlView(themes, $setting.theme)
                }
            }
            .labeledContentStyle(.vertical)
            Group {
                LabeledContent("autoStart"){
                    SegmentedControlView(autoStart, $setting.autoStart)
                }
                LabeledContent("showTimeRemaining"){
                    SegmentedControlView(toggle, $setting.showTimeRemaining)
                }
                LabeledContent("generateQRCode"){
                    SegmentedControlView(toggle, $setting.enableShowQRCode)
                }
                LabeledContent("showVerificationCode"){
                    SegmentedControlView(toggle, $setting.showCode)
                }
                LabeledContent("enableDelete"){
                    SegmentedControlView(toggle, $setting.enableDelete)
                }
                LabeledContent("enableEditing"){
                    SegmentedControlView(toggle, $setting.enableEdit)
                }
                LabeledContent("copyToClipboard"){
                    SegmentedControlView(toggle, $setting.enableClipBoard)
                }
                Slider(value: $setting.radius, in: 0...35) {
                    Text("roundedCorners\(Text("\(setting.radius, specifier: "%.0f")"))")
                    IconButton<Image>("arrow.triangle.2.circlepath", { setting.radius = 8.0 })
                }
            }
            .labeledContentStyle(.toggleSegmentedControl)
            HStack {
                Spacer()
                Button(action: {
                    SFSafariApplication.showPreferencesForExtension(withIdentifier: "com.moneko.auth2fa.Safari-Extension") { error in
                        if let error = error {
                            // Handle the error
                        }
                    }
                }, label: {
                    Text("Open Extension Preferences")
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 5)
                        .background(Color(.controlAccentColor))
                        .clipShape(RoundedRectangle(cornerRadius: 50))
                        .onHoverStyle(radius: 50)
                })
                Spacer()
            }
        }
        .frame(width: 300)
        .padding()
        .buttonStyle(.plain)
        .background(.ultraThinMaterial)
        .environment(\.locale, .init(identifier: getLocale(locale: setting.locale)))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

