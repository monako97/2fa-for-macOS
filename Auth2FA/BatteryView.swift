//
//  BatteryView.swift
//  Auth2FA
//
//  Created by Moneko on 2023/12/27.
//

//
//  SettingsView.swift
//  Auth2FA
//
//  Created by neko Mo on 2023/1/1.
//

import SwiftUI

struct BatteryCardView<CardView: View>: View {
    @EnvironmentObject var setting: SettingModel
    let option: (title: Optional<String>, context: CardView)
    init(_ title: String, _ context: CardView) {
        self.option = (title, context)
    }
    init(_ context: CardView) {
        self.option = (title: nil, context)
    }
    var body: some View {
        if let title = option.title {
            Text(LocalizedStringKey(title)).font(.system(size: 15, weight: .medium))
        }
        option.context
            .padding(10)
            .background(Color.accentColor.opacity(0.1))
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: setting.radius))
    }
    
}

struct BatteryView: View {
    @EnvironmentObject var setting: SettingModel
    @EnvironmentObject var battery: BatteryModel
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            Group {
                BatteryCardView("Health", VStack{
                    LabeledContent("Battery Health"){
                        Text("\(battery.health)%")
                    }
                    LabeledContent("Nominal Battery Health") {
                        Text("\(battery.nominalHealth)%")
                    }
                    LabeledContent("Battery Health Condition"){
                        Text(LocalizedStringKey(battery.batteryHealth))
                    }
                    LabeledContent("Design Cycle Count"){
                        Text("\(battery.designCycleCount9C.description) frequency")
                    }
                    LabeledContent("Cycle Count"){
                        Text("\(battery.cycleCount.description) frequency")
                    }
                    LabeledContent("Battery Cell Disconnect Count") {
                        Text("\(battery.batteryCellDisconnectCount.description) frequency")
                    }
                })
                BatteryCardView("Battery", VStack{
                    LabeledContent("Design Capacity"){
                        Text("\(battery.designCapacity) mAh")
                    }
                    LabeledContent("Nominal Charge Capacity") {
                        Text("\(battery.nominalChargeCapacity) mAh")
                    }
                    LabeledContent("Max Capacity"){
                        Text("\(battery.appleRawMaxCapacity) mAh")
                    }
                    LabeledContent("Current Capacity"){
                        HStack {
                            BatteryIconView(level: battery.currentCapacity)
                            Text("\(battery.appleRawCurrentCapacity) mAh")
                        }
                    }
                    LabeledContent("Battery Installed") {
                        Text(LocalizedStringKey(battery.batteryInstalled.description))
                    }
                    LabeledContent("Temperature") {
                        Text("\(battery.temperature / 100)°C")
                    }
                    LabeledContent("Time Remaining") {
                        Text("\(String(format: "%d:%02d", battery.timeRemaining / 60, battery.timeRemaining % 60))")
                    }
                    LabeledContent("Is Charging") {
                        Text(LocalizedStringKey(battery.isCharging.description))
                    }
                    LabeledContent("Fully Charged") {
                        Text(LocalizedStringKey(battery.fullyCharged.description))
                    }
                    LabeledContent("At Critical Level") {
                        Text(LocalizedStringKey(battery.atCriticalLevel.description))
                    }
                    LabeledContent("Instant Amperage"){
                        Text("\(battery.instantAmperage / 1000) A")
                    }
                    LabeledContent("Apple Raw Battery Voltage"){
                        Text("\(battery.appleRawBatteryVoltage / 1000) V")
                    }
                    LabeledContent("Power"){
                        Text("\(battery.power) W")
                    }
                    LabeledContent("Powered by AC") {
                        Text(LocalizedStringKey(battery.externalConnected.description))
                    }
                })
            }
        }
        .frame(minWidth: 288)
        .toggleStyle(.switch)
        .labeledContentStyle(.spaceBetween)
        .padding()
        .background(.ultraThinMaterial)
        .environment(\.locale, .init(identifier: getLocale(locale: setting.locale)))
        
    }
}

struct BatteryView_Previews: PreviewProvider {
    static var previews: some View {
        BatteryView()
    }
}

