//
//  BatteryServiceHandler.swift
//  BluetoothTest
//
//  Created by Mahnoor Khan on 17/12/2019.
//  Copyright © 2019 Mahnoor Khan. All rights reserved.
//

import Foundation
import CoreBluetooth

class BatteryServiceHandler {
    static let shared = BatteryServiceHandler()
    
    func didDiscoverBatteryCharacteristics(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            switch characteristic.uuid {
            case HeaterServicesCharacteristics.batteryLevel.getUUID():
                setCharacteristics(.batteryLevel, characteristic)
                setNotification(true, for: characteristic)
                readValue(for: characteristic)
            default:
                break
            }
        }
    }
    
    func didUpdateBatteryCharacteristics(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case HeaterServicesCharacteristics.batteryLevel.getUUID():
            let level = CharacteristicHandler.readUInt8Value(data: characteristic.value)
            DataManager.shared.batteryLevelUpdated(battery: String(level))
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
    func setCharacteristics(_ type: HeaterServicesCharacteristics, _ characteristic: CBCharacteristic) {
        BLEManager.shared.characteristicMap.append((type, characteristic))
    }
    
    func setNotification(_ enabled: Bool, for characteristic: CBCharacteristic) {
        if characteristic.properties.contains(.notify) {
            BLEManager.shared.currentPeripheral?.setNotifyValue(enabled, for: characteristic)
        }
    }
    
    func readValue(for characteristic: CBCharacteristic) {
        if characteristic.properties.contains(.read) {
            BLEManager.shared.currentPeripheral?.readValue(for: characteristic)
        }
    }
}
