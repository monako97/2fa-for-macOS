//
//  SegmentedControlView.swift
//  moneko
//
//  Created by neko Mo on 2022/12/29.
//

import SwiftUI

struct TabObject<TabKey: Hashable>: Hashable {
    let id = UUID()
    let label: String
    let key: TabKey
    var icon: String? = nil
    var activeIcon: String? = nil

    static func == (lhs: TabObject<TabKey>, rhs: TabObject<TabKey>) -> Bool {
        return lhs.label == rhs.label && lhs.key == rhs.key && lhs.icon == rhs.icon && lhs.activeIcon == rhs.activeIcon
    }
}

struct SegmentedControlView<TabKey: Hashable>: View {
    @EnvironmentObject var settingModel: SettingModel
    @Environment(\.colorScheme) var colorScheme
    let tabs: [TabObject<TabKey>]
    @Binding var currentTab: TabKey
    var onChange: ((_ current: TabKey) -> ())? = {k in }
    @Namespace var animation
    
    func isActive(key: TabKey) -> Bool {
        return self.currentTab == key
    }
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.1.id){ (index, tab) in
                let active = isActive(key: tab.key)
                if index > tabs.startIndex {
                    Divider().frame(height: 16).opacity(0.4)
                }
                if tab.icon == nil {
                    Text(LocalizedStringKey(tab.label))
                        .foregroundColor(active ? .white : colorScheme == .light ? .secondary : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background{
                            if active == true {
                                makeRoundedRectangle(animation: animation, radius: settingModel.radius)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onTapGesture(tab: tab)
                        }
                } else {
                    let icon = active ? (tab.activeIcon ?? tab.icon) : tab.icon
                    Label(LocalizedStringKey(tab.label), systemImage: icon!)
                        .foregroundColor(active ? .white : colorScheme == .light ? .secondary : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background{
                            if active == true {
                                makeRoundedRectangle(animation: animation, radius: settingModel.radius)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onTapGesture(tab: tab)
                        }
                }
                
            }
        }
        .padding(2)
        .background(Color.accentColor.opacity(0.1))
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: settingModel.radius))
        .environment(\.locale, .init(identifier: getLocale(locale: settingModel.locale)))
    }
    func onTapGesture(tab: TabObject<TabKey>) -> Void {
        withAnimation{
            self.currentTab = tab.key
        }
        self.onChange?(tab.key)
    }
}

func makeRoundedRectangle(animation: Namespace.ID, radius: CGFloat) -> some View {
    return RoundedRectangle(cornerRadius: radius,style: .continuous)
        .fill(Color.accentColor)
        .matchedGeometryEffect(id: "SegmentedControl", in: animation)
        .background(Color.clear.clipShape(RoundedRectangle(cornerRadius: radius,style: .continuous)))
        .shadow(radius: 1, x: 1, y: 1)
}

struct SegmentedControlView_Previews: PreviewProvider {
    static var previews: some View {
        SegmentedControlView(tabs: [
            TabObject(label: "验证码", key: 1),
            TabObject(label: "扫码", key: 2)
        ], currentTab: .constant(1))
    }
}
