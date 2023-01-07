//
//  OnHoverStyle.swift
//  moneko
//
//  Created by neko Mo on 2022/12/28.
//

import SwiftUI

struct OnHoverStyle: ViewModifier {
    @EnvironmentObject private var settingModel: SettingModel
    var radius: CGFloat? = nil
    @State private var isHovered = false
    
    init(radius: CGFloat? = nil) {
        self.radius = radius
    }
    
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: radius ?? settingModel.radius))
            .shadow(color: .primary.opacity(0.1), radius: isHovered ? 2 : 0.5, x: 0, y: isHovered ? 1 : 0)
            .onHover { isHovered in
                withAnimation {
                    self.isHovered = isHovered
                }
            }
    }
}

extension View {
    func onHoverStyle(radius: CGFloat? = nil) -> some View {
        self.modifier(OnHoverStyle(radius: radius))
    }
}
