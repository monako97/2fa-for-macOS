//
//  IconfontPickerView.swift
//  CodeSnippet
//
//  Created by neko Mo on 2024/3/21.
//

import SwiftUI


let allIcons = Array(Set(iconfontOne.keys).union(iconfontTwo.keys)).sorted()

struct IconPickerView: View {
    @EnvironmentObject private var setting: SettingModel
    @State var isHovered: String? = nil
    @State var isOpened: Bool = false
    @Binding var selection: String?
    var size: CGFloat = 14
    
    func getIcon<T: View>(_ key: String, _ text: T) -> some View {
        VStack(spacing: 10){
            text
        }
        .frame(minWidth: size, maxWidth: .infinity, minHeight: 32)
        .background(selection == key || isHovered == key ? Color.accentColor.opacity(0.3) : Color.clear, in: RoundedRectangle(cornerRadius: 8))
        .onHover{ h in
            isHovered = h ? key : nil
        }
        .onTapGesture {
            selection = key
            isOpened = false
        }
    }
    
    var body: some View {
        Button(action: {
            isOpened = true
        } ){
            IconView(selection, size).popover(isPresented: $isOpened) {
                let fixedWid = GridItem(.fixed(60))
                ScrollView {
                    LazyVGrid(
                        columns: [fixedWid,fixedWid,fixedWid,fixedWid],
                        alignment: .center
                    ){
                        ForEach(allIcons, id: \.self) { key in
                            getIcon(key, IconView(key, 16))
                        }
                        getIcon("", Text("clear"))
                    }
                    .padding()
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct IconfontPickerView_Previews: PreviewProvider {
    static var previews: some View {
        IconPickerView(selection: .constant("github"))
    }
}
