//
//  ModalView.swift
//  Auth2FA
//
//  Created by neko Mo on 2022/12/31.
//

import SwiftUI

struct ModalView<MessageView: View>: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var setting: SettingModel
    let option: (message: MessageView, secondaryMessage: String?, alignment: VerticalAlignment, okText: String, cancelText: String, destructive: () -> Void)
    
    init(_ message: MessageView, _ secondaryMessage: String? = nil, alignment: VerticalAlignment = .center, okText: String = "confirm", cancelText: String = "cancel", destructive: @escaping () -> Void) {
        self.option = (message, secondaryMessage, alignment, okText, cancelText, destructive)
    }
    
    
    var body: some View {
        VStack (spacing: 0) {
            option.message
            if option.secondaryMessage != nil {
                Text(LocalizedStringKey(option.secondaryMessage!))
                    .foregroundColor(.primary.opacity(0.6))
                    .font(Font.system(size: 12))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            HStack (spacing: 10) {
                Button(action: {
                    self.presentation.wrappedValue.dismiss()
                }, label: {
                    Text(LocalizedStringKey(option.cancelText))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 20)
                        .background(Color.accentColor.opacity(0.1))
                        .onHoverStyle()
                })
                Button(action: {
                    self.presentation.wrappedValue.dismiss()
                    self.option.destructive()
                }, label: {
                    Text(LocalizedStringKey(option.okText))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 20)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .onHoverStyle()
                })
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .buttonStyle(.plain)
        }
        .environment(\.locale, .init(identifier: getLocale(locale: setting.locale)))
    }
}

struct ModalView_Previews: PreviewProvider {
    static var previews: some View {
        ModalView(Text("hellow"), destructive: {})
    }
}
