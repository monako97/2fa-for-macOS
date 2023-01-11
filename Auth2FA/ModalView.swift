//
//  ModalView.swift
//  Auth2FA
//
//  Created by neko Mo on 2022/12/31.
//

import SwiftUI

struct ModalView<MessageView: View>: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var settingModel: SettingModel
    let message: () -> MessageView
    let destructive: () -> ()
    let secondaryMessage: String?
    let alignment: VerticalAlignment
    let okText: String
    let cancelText: String
    
    init(message: @escaping () -> MessageView, destructive: @escaping () -> Void, secondaryMessage: String? = nil, alignment: VerticalAlignment = .center, okText: String = "Confirm", cancelText: String = "Cancel") {
        self.message = message
        self.destructive = destructive
        self.secondaryMessage = secondaryMessage
        self.alignment = alignment
        self.okText = okText
        self.cancelText = cancelText
    }
    
    var body: some View {
        VStack (spacing: 0) {
            self.message()
            if self.secondaryMessage != nil {
                Text(LocalizedStringKey(self.secondaryMessage!))
                    .foregroundColor(.primary.opacity(0.6))
                    .font(Font.system(size: 12))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            HStack (spacing: 10) {
                Button(action: {
                    self.presentation.wrappedValue.dismiss()
                }, label: {
                    Text(LocalizedStringKey(self.cancelText))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 20)
                        .onHoverStyle()
                })
                Button(action: {
                    self.presentation.wrappedValue.dismiss()
                    self.destructive()
                }, label: {
                    Text(LocalizedStringKey(self.okText))
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
        .blurBackground()
        .environment(\.locale, .init(identifier: getLocale(locale: settingModel.locale)))
    }
}

struct ModalView_Previews: PreviewProvider {
    static var previews: some View {
        ModalView(message: {
            Text("hellow")
        }, destructive: {})
    }
}
