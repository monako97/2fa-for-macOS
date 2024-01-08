//
//  Battery.swift
//  Auth2FA
//
//  Created by Moneko on 2023/12/26.
//

import IOKit.ps
import SwiftUI

let emptyStr = "-"
let emptyInt32: Int32 = 0
let emptyInt64: Int64 = 0

struct AdapterInfo: Identifiable {
    let id = UUID()
    var AdapterID: Int32
    var AdapterVoltage: Int32
    var Current: Int32
    var Description: String
    var FamilyCode: Int64
    var FwVersion: String
    var HwVersion: String
    var IsWireless: Bool
    var Manufacturer: String
    var Model: String
    var Name: String
    var PMUConfiguration: Int32
    var SerialString: String
    var UsbHvcHvcIndex: Int32
    
    init(_ info: [String: Any]) {
        self.AdapterID = info["AdapterID"] as? Int32 ?? emptyInt32
        self.AdapterVoltage = info["AdapterVoltage"] as? Int32 ?? emptyInt32
        self.Current = info["Current"] as? Int32 ?? emptyInt32
        self.Description = info["Description"] as? String ?? emptyStr
        self.FamilyCode = info["FamilyCode"] as? Int64 ?? emptyInt64
        self.FwVersion = info["FwVersion"] as? String ?? emptyStr
        self.HwVersion = info["HwVersion"] as? String ?? emptyStr
        self.IsWireless = info["IsWireless"] as? Bool ?? false
        self.Manufacturer = info["Manufacturer"] as? String ?? emptyStr
        self.Model = info["Model"] as? String ?? emptyStr
        self.Name = info["Name"] as? String ?? emptyStr
        self.PMUConfiguration = info["PMUConfiguration"] as? Int32 ?? emptyInt32
        self.SerialString = info["SerialString"] as? String ?? emptyStr
        self.UsbHvcHvcIndex = info["UsbHvcHvcIndex"] as? Int32 ?? emptyInt32
    }
}

final class BatteryModel: NSObject, ObservableObject {
    let keys = [
        "DesignCapacity",
        "DesignCycleCount9C",
        "CycleCount",
        "IsCharging",
        "CurrentCapacity",
        "NominalChargeCapacity",
        "AppleRawMaxCapacity",
        "AppleRawCurrentCapacity",
        "BatteryCellDisconnectCount",
        "ExternalConnected",
        "Amperage",
        "InstantAmperage",
        "Voltage",
        "AppleRawBatteryVoltage",
        "Temperature",
        "TimeRemaining",
        "AtCriticalLevel",
        "BatteryInstalled",
        "FullyCharged",
        "AppleRawAdapterDetails"
    ]
    @Published @objc var batteryHealth: String = emptyStr
    @Published @objc var designCapacity: Int64 = emptyInt64 {
        didSet {
            getHealth()
        }
    }
    @Published @objc var designCycleCount9C: Int64 = emptyInt64
    @Published @objc var cycleCount: Int64 = emptyInt64
    @Published @objc var health: Int64 = emptyInt64 {
        didSet {
            getBatteryHealth()
        }
    }
    @Published @objc var currentCapacity: Int64 = emptyInt64
    @Published @objc var appleRawMaxCapacity: Int64 = emptyInt64 {
        didSet {
            getNominalHealth()
            getHealth()
        }
    }
    @Published @objc var isCharging: Bool = false
    @Published @objc var externalConnected: Bool = false
    @Published @objc var batteryCellDisconnectCount: Int64 = emptyInt64
    @Published @objc var nominalChargeCapacity: Int64 = emptyInt64 {
        didSet {
            getNominalHealth()
        }
    }
    @Published @objc var nominalHealth: Int64 = emptyInt64
    @Published @objc var appleRawCurrentCapacity: Int64 = emptyInt64
    @Published @objc var voltage: Int64 = emptyInt64 {
        didSet {
            getPower()
        }
    }
    @Published @objc var appleRawBatteryVoltage: Int64 = emptyInt64
    @Published @objc var amperage: Int64 = emptyInt64 {
        didSet {
            getPower()
        }
    }
    @Published @objc var instantAmperage: Int64 = emptyInt64
    @Published @objc var power: Int64 = emptyInt64
    @Published @objc var temperature: Int64 = emptyInt64
    @Published @objc var timeRemaining: Int64 = emptyInt64
    @Published @objc var atCriticalLevel: Bool = false
    @Published @objc var batteryInstalled: Bool = false
    @Published @objc var fullyCharged: Bool = false
    @Published var appleRawAdapterDetails: [AdapterInfo] = []
    
    override init() {
        super.init()
        refresh()
    }
    
    func refresh() {
        getPowerSourceInfo()
    }
    func getPower() {
        self.power = Int64(Double(self.amperage * self.voltage) / 1000000) + Int64(Double(self.appleRawBatteryVoltage) / 1000000)
    }
    func getNominalHealth() {
        if (self.nominalChargeCapacity != 0) && (self.appleRawMaxCapacity != 0) {
            self.nominalHealth = Int64(round(Double(self.appleRawMaxCapacity) / Double(self.nominalChargeCapacity) * 100))
        }
    }
    func getHealth() {
        if (self.designCapacity != 0) && (self.appleRawMaxCapacity != 0) {
            self.health = Int64(round(Double(self.appleRawMaxCapacity) / Double(self.designCapacity) * 100.0))
        }
    }
    func getBatteryHealth() {
        if self.health != 0 {
            self.batteryHealth = self.health >= 80 ? "Good" : self.health >= 60 ? "Replace" : "Service"
        }
    }
    
    func getRetainedValue() -> [String: CustomStringConvertible] {
        var result: [String: CustomStringConvertible] = [:]
        let platformExpert = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceNameMatching("AppleSmartBattery"))
        defer { IOObjectRelease(platformExpert) }
        
        self.keys.forEach({ key in
            let val = IORegistryEntryCreateCFProperty(platformExpert,
                                                      key as CFString,
                                                      kCFAllocatorDefault, 0).takeRetainedValue()
            
            result.updateValue(val as! CustomStringConvertible, forKey: key)
        })
        return result
    }
    func getPowerSourceInfo() {
        let desc = getRetainedValue()
        
        desc.keys.forEach({ key in
            if key == "AppleRawAdapterDetails" {
                self.appleRawAdapterDetails = (desc[key] as? [[String: Any]] ?? []).map({ info in
                    return AdapterInfo(info)
                });
            } else {
                self.setValue(desc[key], forKey: key.toLowerCamelCase())
            }
        })
    }
}
