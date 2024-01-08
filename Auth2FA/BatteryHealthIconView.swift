//
//  BatteryHealthIconView.swift
//  Auth2FA
//
//  Created by Moneko on 2023/12/29.
//

import SwiftUI

struct BatteryHealthIconView: View {
    @EnvironmentObject private var battery: BatteryModel
    @State private var showBatteryHealth: Bool = false
    
    func getHealthColor(_ health: Int64) -> Color {
        return Color(health < 60 ? .systemRed : health < 80 ? .orange : .systemGreen)
    }
    var body: some View {
        IconButton(
            Image("battery.health"),
            action: {
                self.showBatteryHealth = true
            }
        )
        .foregroundColor(getHealthColor(battery.health).opacity(0.9))
        .popover(isPresented: $showBatteryHealth, content: {
            BatteryView()
        })
    }
    
    func batteryColor() -> Color {
        // 在此根据需要设定电池颜色逻辑
        return .green
    }
}
