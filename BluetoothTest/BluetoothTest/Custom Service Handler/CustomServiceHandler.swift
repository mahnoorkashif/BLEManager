//
//  CustomServiceHandle.swift
//  BluetoothTest
//
//  Created by Mahnoor Khan on 20/12/2019.
//  Copyright © 2019 Mahnoor Khan. All rights reserved.
//

import Foundation
import CoreBluetooth

class CustomServiceHandler {
    static let shared = CustomServiceHandler()
    
    func didDiscoverBatteryCharacteristics(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        print("Custom Service Handler Called")
        for characteristic in characteristics {
            switch characteristic.uuid {
            case HeaterServicesCharacteristics.systemStats.getUUID():
                BLEManager.shared.setCharacteristics(HeaterServicesCharacteristics.systemStats, characteristic)
                BLEManager.shared.setNotification(true, for: characteristic)
                BLEManager.shared.readValue(for: characteristic)
            case HeaterServicesCharacteristics.initialOnTime.getUUID():
                BLEManager.shared.setCharacteristics(HeaterServicesCharacteristics.initialOnTime, characteristic)
                BLEManager.shared.readValue(for: characteristic)
            case HeaterServicesCharacteristics.waveOnTime.getUUID():
                BLEManager.shared.setCharacteristics(HeaterServicesCharacteristics.waveOnTime, characteristic)
                BLEManager.shared.readValue(for: characteristic)
            case HeaterServicesCharacteristics.waveOffTime.getUUID():
                BLEManager.shared.setCharacteristics(HeaterServicesCharacteristics.waveOffTime, characteristic)
                BLEManager.shared.readValue(for: characteristic)
            case HeaterServicesCharacteristics.waveTimeLimit.getUUID():
                BLEManager.shared.setCharacteristics(HeaterServicesCharacteristics.waveTimeLimit, characteristic)
                BLEManager.shared.readValue(for: characteristic)
            case HeaterServicesCharacteristics.tempUpperLimit.getUUID():
                BLEManager.shared.setCharacteristics(HeaterServicesCharacteristics.tempUpperLimit, characteristic)
                BLEManager.shared.readValue(for: characteristic)
            case HeaterServicesCharacteristics.controlStatus.getUUID():
                BLEManager.shared.setCharacteristics(HeaterServicesCharacteristics.controlStatus, characteristic)
                BLEManager.shared.setNotification(true, for: characteristic)
                BLEManager.shared.readValue(for: characteristic)
            default:
                break
            }
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
