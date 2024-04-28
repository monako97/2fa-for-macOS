//
//  GridPickerView.swift
//  Auth2FA
//
//  Created by neko Mo on 2023/1/19.
//

import SwiftUI

struct GridPickerView: View {
    @EnvironmentObject private var setting: SettingModel
    @State var isHovered: String? = nil
    @State var isOpened: Bool = false
    @Binding var selection: String?
    var size: CGFloat = 16

    func getTag(_ key: String, _ text: Text) -> some View {
        text
            .tag(key)
            .frame(minWidth: size * 3, maxWidth: .infinity, minHeight: 28)
            .background(isHovered == key ? Color.accentColor.opacity(0.3) : Color.clear)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: setting.radius))
            .onHover{ h in
                isHovered = h ? key : nil
            }
            .onTapGesture {
                selection = key
                isOpened = false
            }
    }
    var body: some View {
        LabeledContent("icon"){
            
            let selectionIcon = Iconfont(rawValue: selection ?? "")?.description
            let label = selectionIcon != nil ? Text(selectionIcon!).font(.iconfont(size: size)) : Text("icon").foregroundColor(Color.primary.opacity(0.3)).font(.system(size: 12, weight: .light))
            
            Button(action: {
                isOpened = true
            }, label: {
                label.popover(isPresented: $isOpened) {
                    let fixedWid = GridItem(.fixed(size * 3))
                    LazyVGrid(
                        columns: [fixedWid,fixedWid,fixedWid,fixedWid], alignment: .listRowSeparatorTrailing){
                            ForEach(Iconfont.allCases) { icon in
                                getTag(icon.rawValue, Text(icon.description)
                                    .font(.iconfont(size: size)))
                            }
                            getTag("", Text("clear"))
                                .environment(\.locale, .init(identifier: getLocale(locale: setting.locale)))
                        }
                        .padding()
                }
            })
            .buttonStyle(.plain)
        }
    }
}

struct GridPickerView_Previews: PreviewProvider {
    static var previews: some View {
        GridPickerView(selection: .constant("github"))
    }
}
