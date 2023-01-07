//
//  BlurBackground.swift
//  Auth2FA
//
//  Created by neko Mo on 2023/1/1.
//

import SwiftUI

struct BlurBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let blurView = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: 100, height: 100))
        blurView.blendingMode = NSVisualEffectView.BlendingMode.behindWindow
        blurView.material = NSVisualEffectView.Material.hudWindow
        blurView.isEmphasized = true
        blurView.state = NSVisualEffectView.State.active
        
        return blurView;
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        NSLog("updateNSView")
    }
    func test() -> some View {
        return self
    }
};

extension View {
    func blurBackground() -> some View {
        self.background(BlurBackground().test())
    }
}
