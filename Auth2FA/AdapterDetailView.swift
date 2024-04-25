//
//  AdapterDetailView.swift
//  Auth2FA
//
//  Created by Moneko on 2023/12/29.
//

import SwiftUI

struct AdapterDetailIconView: View {
    @EnvironmentObject var battery: BatteryModel
    @EnvironmentObject var time: TimeModel
    @State private var showAdapterDetail: Bool = false
    var body: some View {
        let powerIcon = battery.appleRawAdapterDetails.isEmpty ? "power.plug.off" : "power.plug";
        
        IconButton<Image>(
            Image(powerIcon),
            action: {
                self.showAdapterDetail = true
            }
        )
        .popover(isPresented: $showAdapterDetail, content: {
            AdapterDetailView()
        })
        .task(id: time.time, priority: .background) {
            battery.refresh()
        }
    }
}

struct AdapterDetailView: View {
    @EnvironmentObject var setting: SettingModel
    @EnvironmentObject var battery: BatteryModel
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            Text(LocalizedStringKey("Apple Raw Adapter Details")).font(.system(size: 15, weight: .medium))
            
            Group {
                if battery.appleRawAdapterDetails.isEmpty {
                    Text("无").padding().foregroundStyle(.secondary)
                } else {
                    ForEach(battery.appleRawAdapterDetails) { adapter in
                        BatteryCardView(VStack {
                            LabeledContent("Name") {
                                Text(String(describing: adapter.Name))
                            }
                            LabeledContent("Serial String") {
                                Text(adapter.SerialString.description)
                            }
                            LabeledContent("Adapter ID") {
                                Text(adapter.AdapterID.description)
                            }
                            LabeledContent("Description") {
                                Text(adapter.Description.description)
                            }
                            LabeledContent("Manufacturer") {
                                Text(adapter.Manufacturer.description)
                            }
                            LabeledContent("Hw Version") {
                                Text(adapter.HwVersion.description)
                            }
                            LabeledContent("Fw Version") {
                                Text(adapter.FwVersion.description)
                            }
                            LabeledContent("Model") {
                                Text(adapter.Model.description)
                            }
                            LabeledContent("Adapter Voltage") {
                                Text("\(adapter.AdapterVoltage / 1000) V")
                            }
                            LabeledContent("Current") {
                                Text("\(adapter.Current / 1000) A")
                            }
                            LabeledContent("Family Code") {
                                Text(adapter.FamilyCode.description)
                            }
                            LabeledContent("Is Wireless") {
                                Text(LocalizedStringKey(adapter.IsWireless.description))
                            }
                            LabeledContent("PMU Configuration") {
                                Text(adapter.PMUConfiguration.description)
                            }
                            LabeledContent("Usb Hvc Hvc Index") {
                                Text(adapter.UsbHvcHvcIndex.description)
                            }
                        })
                    }
                }
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

struct AdapterDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AdapterDetailView()
    }
}

