//
//  SettingsView.swift
//  Auth2FA
//
//  Created by neko Mo on 2023/1/1.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingModel: SettingModel
    
    var body: some View {
        Form {
            Group {
                LabeledContent(content: {
                    SegmentedControlView(tabs: settingModel.locales, currentTab: $settingModel.locale)
                }, label: {
                    Text("Language")
                })
                LabeledContent(content: {
                    SegmentedControlView(tabs: settingModel.statusMenuType, currentTab: $settingModel.statusMenu)
                }, label: {
                    Text("View")
                })
                LabeledContent(content: {
                    SegmentedControlView(tabs: settingModel.themes, currentTab: $settingModel.theme)
                }, label: {
                    Text("Theme")
                })
                HStack (alignment: .lastTextBaseline) {
                    Slider(value: $settingModel.radius, in: 0...50) {
                        Text("roundedCorners\(Text("\(settingModel.radius, specifier: "%.0f")"))")
                    }
                    IconButton(
                        icon: Image(systemName: "arrow.triangle.2.circlepath"),
                        action: {
                            settingModel.radius = 8.0
                        }
                    )
                }
            }
            .labeledContentStyle(.vertical)
            LazyVGrid(columns: [GridItem(.flexible())], alignment: .listRowSeparatorTrailing){
                Toggle("showTimeRemaining", isOn: $settingModel.showTimeRemaining)
                Toggle("generateQRCode", isOn: $settingModel.enableShowQRCode)
                Toggle("showVerificationCode", isOn: $settingModel.showCode)
                Toggle("enableDelete", isOn: $settingModel.enableDelete)
                Toggle("enableEditing", isOn: $settingModel.enableEdit)
                Toggle("copyToClipboard", isOn: $settingModel.enableClipBoard)
            }
            .labeledContentStyle(.reverse)
            .frame(width: 300, height: 200)
        }
        .padding()
        .toggleStyle(.switch)
        .buttonStyle(.plain)
        .background(.ultraThinMaterial)
        .environment(\.locale, .init(identifier: getLocale(locale: settingModel.locale)))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

