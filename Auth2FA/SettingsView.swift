//
//  SettingsView.swift
//  Auth2FA
//
//  Created by neko Mo on 2023/1/1.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var setting: SettingModel
    
    var body: some View {
        Form {
            Group {
                LabeledContent(content: {
                    SegmentedControlView(locales, $setting.locale)
                }, label: {
                    Text("language")
                })
                LabeledContent(content: {
                    SegmentedControlView(sceneModes, $setting.sceneMode)
                }, label: {
                    Text("view")
                })
                LabeledContent(content: {
                    SegmentedControlView(themes, $setting.theme)
                }, label: {
                    Text("theme")
                })
                HStack (alignment: .lastTextBaseline) {
                    Slider(value: $setting.radius, in: 0...50) {
                        Text("roundedCorners\(Text("\(setting.radius, specifier: "%.0f")"))")
                    }
                    IconButton<Image>("arrow.triangle.2.circlepath",
                        {
                            setting.radius = 8.0
                        }
                    )
                }
            }
            .labeledContentStyle(.vertical)
            LazyVGrid(columns: [GridItem(.flexible())], alignment: .listRowSeparatorTrailing){
                Toggle("showTimeRemaining", isOn: $setting.showTimeRemaining)
                Toggle("generateQRCode", isOn: $setting.enableShowQRCode)
                Toggle("showVerificationCode", isOn: $setting.showCode)
                Toggle("enableDelete", isOn: $setting.enableDelete)
                Toggle("enableEditing", isOn: $setting.enableEdit)
                Toggle("copyToClipboard", isOn: $setting.enableClipBoard)
            }
            .labeledContentStyle(.reverse)
            .frame(width: 300, height: 200)
        }
        .padding()
        .toggleStyle(.switch)
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

