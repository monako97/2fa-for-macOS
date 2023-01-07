//
//  IconButtonView.swift
//  Auth2FA
//
//  Created by neko Mo on 2022/12/31.
//

import SwiftUI

struct IconButton<IconView: View>: View {
    let icon: IconView
    let hoverIcon: IconView
    let action: () -> ()
    @State var isHovered: Bool = false
    
    init(icon: IconView, hoverIcon: IconView? = nil, action: (() -> ())? = nil) {
        self.icon = icon
        self.hoverIcon = hoverIcon ?? icon
        self.action = action ?? {}
    }
    
    var body: some View {
        Button(action: action, label: {
            if isHovered == true {
                hoverIcon.foregroundColor(isHovered ? .accentColor : .primary)
            } else {
                icon
            }
        })
        .onHover{ isHovered in
            withAnimation {
                self.isHovered = isHovered
            }
        }
    }
}

struct IconButton_Previews: PreviewProvider {
    static var previews: some View {
        IconButton(
            icon: Image(systemName: "power.circle"),
            hoverIcon: Image(systemName: "power.circle.fill"),
            action: {}
        )
    }
}
