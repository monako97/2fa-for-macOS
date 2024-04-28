//
//  RingView.swift
//  Auth2FA
//
//  Created by neko Mo on 2023/1/7.
//

import SwiftUI

struct RingView<TextView: View>: View {
    var text: TextView? = nil
    let total: CGFloat
    let percent: CGFloat
    let strokeStyle: StrokeStyle = StrokeStyle(
        lineWidth: 2,
        dash: [1]
    )
    var body: some View {
        let progress = 1 - percent / total
        let color = Color(progress < 0.5 ? .green : progress < 0.65 ? .systemOrange : progress < 0.75 ? .orange : .red)
        
        return ZStack {
            Circle()
                .stroke(.primary.opacity(0.2), style: strokeStyle)
            Circle()
                .trim(from: progress, to: 1)
                .stroke(color.opacity(0.8), style: strokeStyle)
                .rotationEffect(Angle(degrees: 90))
                .rotation3DEffect(Angle(degrees: 180), axis: (x: 1, y: 0, z: 0))
            text?.foregroundColor(progress == 1 ? .primary : color.opacity(0.9))
                .highPerformanceShadow(color: .primary.opacity(0.2), radius: 0.5, x: 0, y: 0)
        }
    }
}

struct RingView_Previews: PreviewProvider {
    static var previews: some View {
        RingView<EmptyView>(total: 20, percent: 2)
    }
}
