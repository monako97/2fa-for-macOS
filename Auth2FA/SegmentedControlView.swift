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
    
    init(_ label: String, _ key: TabKey, _ icon: String? = nil, _ activeIcon: String? = nil) {
        self.label = label
        self.key = key
        self.icon = icon
        self.activeIcon = activeIcon
    }
    static func == (lhs: TabObject<TabKey>, rhs: TabObject<TabKey>) -> Bool {
        return lhs.label == rhs.label && lhs.key == rhs.key && lhs.icon == rhs.icon && lhs.activeIcon == rhs.activeIcon
    }
}

struct SegmentedControlView<TabKey: Hashable>: View {
    @Namespace var animation
    @EnvironmentObject var setting: SettingModel
    @Environment(\.colorScheme) var colorScheme
    let tabs: [TabObject<TabKey>]
    @Binding var current: TabKey
    let onChange: (_ current: TabKey) -> ()
    
    init(_ tabs: [TabObject<TabKey>], _ current: Binding<TabKey>, _ onChange: ((_ current: TabKey) -> ())? = nil) {
        self.tabs = tabs
        self._current = current
        self.onChange = onChange ?? {k in}
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.1.id){ (index, tab) in
                let active = current == tab.key
                if index > tabs.startIndex {
                    Divider().frame(height: 16).opacity(0.4)
                }
                if tab.icon == nil {
                    Text(LocalizedStringKey(tab.label))
                        .foregroundColor(active ? .white : colorScheme == .light ? .secondary : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background{
                            if active {
                                makeRoundedRectangle(animation, setting.radius)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation{current = tab.key}
                            onChange(tab.key)
                        }
                } else {
                     Label(LocalizedStringKey(tab.label), systemImage: (active ? (tab.activeIcon ?? tab.icon) : tab.icon)!)
                    .foregroundColor(active ? .white : colorScheme == .light ? .secondary : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background{
                        if active {
                            makeRoundedRectangle(animation, setting.radius)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation{current = tab.key}
                        onChange(tab.key)
                    }
                }
                
            }
        }
        .padding(2)
        .background(Color.accentColor.opacity(0.1))
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: setting.radius))
        .environment(\.locale, .init(identifier: getLocale(locale: setting.locale)))
    }
}

func makeRoundedRectangle(_ animation: Namespace.ID, _ radius: CGFloat) -> some View {
    return RoundedRectangle(cornerRadius: radius,style: .continuous)
        .fill(Color.accentColor)
        .matchedGeometryEffect(id: "SegmentedControl", in: animation)
        .background(Color.clear.clipShape(RoundedRectangle(cornerRadius: radius,style: .continuous)))
        .shadow(radius: 1, x: 1, y: 1)
}
struct SegmentedControlView_Previews: PreviewProvider {
    static var previews: some View {
        SegmentedControlView([
            TabObject("验证码", 1),
            TabObject("扫码", 2)
        ], .constant(1))
    }
}
