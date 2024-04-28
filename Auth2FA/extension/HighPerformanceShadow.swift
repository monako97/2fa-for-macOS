//
//  HighPerformanceShadow.swift
//  Auth2FA
//
//  Created by Moneko on 2024/4/28.
//

import SwiftUI

struct HighPerformanceShadow: ViewModifier {
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    let color: Color
    
    init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color, radius: radius, x: x, y: y)
    }
}

extension View {
    func highPerformanceShadow(color: Color = .primary.opacity(0.1), radius: CGFloat = 1, x: CGFloat = 0, y: CGFloat = 0.5) -> some View {
        self.modifier(HighPerformanceShadow(color: color, radius: radius, x: x, y: y))
    }
}
