//
//  IconButtonView.swift
//  Auth2FA
//
//  Created by neko Mo on 2022/12/31.
//

import SwiftUI

struct IconButton<IconView: View>: View {
    @State var isHovered: Bool = false
    let option: (icon: IconView, hoverIcon: IconView, action: () -> Void)
    init(_ icon: IconView, _ hoverIcon: IconView? = nil, action: (() -> ())? = nil) {
        self.option = (icon, hoverIcon ?? icon, action ?? {})
    }
    init(_ icon: IconView, action: (() -> ())? = nil) {
        self.option = (icon, icon, action ?? {})
    }
    init(_ icon: String,_ hoverIcon: String? = nil, _ action: (() -> ())? = nil) {
        self.option = (Image(systemName: icon) as! IconView,Image(systemName: hoverIcon ?? icon) as! IconView,action ?? {})
    }
    init(_ icon: String, _ action: (() -> ())? = nil) {
        self.option = (Image(systemName: icon) as! IconView,Image(systemName: icon) as! IconView,action ?? {})
    }
    var body: some View {
        Button(action: option.action, label: {
            if isHovered {
                option.hoverIcon.foregroundColor(isHovered ? .accentColor : .primary)
            } else {
                option.icon
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
        IconButton(Image(systemName: "power.circle"), Image(systemName: "power.circle.fill"), action: {})
    }
}
