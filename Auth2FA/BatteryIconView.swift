//
//  BatteryIconView.swift
//  Auth2FA
//
//  Created by Moneko on 2023/12/29.
//

import SwiftUI

struct HalfCircleShape : Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addArc(center: CGPoint(x: rect.minX, y: rect.midY), radius: rect.height , startAngle: .degrees(90), endAngle: .degrees(270), clockwise: true)
        return path
    }
}

struct BatteryIconView : View {
    let level: Int64
    
    func getColor(_ batteryLevel: Int64) -> Color {
        switch batteryLevel {
            case 0...20:
                return Color.red
            case 20...50:
                return Color.yellow
            case 50...100:
                return Color.green
            default:
                return Color.clear
        }
    }
    var body: some View {
        let batteryLevel = CGFloat(Double(level) / 100)
        GeometryReader { geo in
            HStack(spacing: 1) {
                GeometryReader { rectangle in
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(lineWidth: 1)
                    RoundedRectangle(cornerRadius: 2.5)
                        .frame(width: rectangle.size.width - 2 - ((rectangle.size.width - 2) * (1 - batteryLevel)), height: rectangle.size.height - 2)
                        .offset(x: 1, y: 1)
                        .foregroundColor(getColor(level))
                }
                HalfCircleShape()
                .frame(width: geo.size.width / 6, height: geo.size.height / 6)
                
            }
            .padding(.leading)
        }.frame(width: 48, height: 11.5)
    }
}
