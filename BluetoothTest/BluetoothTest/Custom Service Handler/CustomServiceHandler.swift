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
        for characteristic in characteristics {
            switch characteristic.uuid {
            case HeaterServicesCharacteristics.systemStats.getUUID():
                setCharacteristics(HeaterServicesCharacteristics.systemStats, characteristic)
                setNotification(true, for: characteristic)
                readValue(for: characteristic)
            case HeaterServicesCharacteristics.initialOnTime.getUUID():
                setCharacteristics(HeaterServicesCharacteristics.initialOnTime, characteristic)
                readValue(for: characteristic)
            case HeaterServicesCharacteristics.waveOnTime.getUUID():
                setCharacteristics(HeaterServicesCharacteristics.waveOnTime, characteristic)
                readValue(for: characteristic)
            case HeaterServicesCharacteristics.waveOffTime.getUUID():
                setCharacteristics(HeaterServicesCharacteristics.waveOffTime, characteristic)
                readValue(for: characteristic)
            case HeaterServicesCharacteristics.waveTimeLimit.getUUID():
                setCharacteristics(HeaterServicesCharacteristics.waveTimeLimit, characteristic)
                readValue(for: characteristic)
            case HeaterServicesCharacteristics.tempUpperLimit.getUUID():
                setCharacteristics(HeaterServicesCharacteristics.tempUpperLimit, characteristic)
                readValue(for: characteristic)
            case HeaterServicesCharacteristics.controlStatus.getUUID():
                setCharacteristics(HeaterServicesCharacteristics.controlStatus, characteristic)
                setNotification(true, for: characteristic)
                readValue(for: characteristic)
            default:
                break
            }
        }
    }
    
    func didUpdateBatteryCharacteristics(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case HeaterServicesCharacteristics.waveOnTime.getUUID():
            let time = CharacteristicHandler.readUInt16Value(data: characteristic.value)
            DataManager.shared.waveOnTimeUpdated(waveOnTime: time)
        case HeaterServicesCharacteristics.waveOffTime.getUUID():
            let time = CharacteristicHandler.readUInt16Value(data: characteristic.value)
            DataManager.shared.waveOffTimeUpdated(waveOffTime: time)
        case HeaterServicesCharacteristics.systemStats.getUUID():
            let temperature = CharacteristicHandler.readIntValue(data: characteristic.value)
            DataManager.shared.systemStatsUpdated(systemStats: temperature)
        case HeaterServicesCharacteristics.controlStatus.getUUID():
            let status = CharacteristicHandler.readUInt8Value(data: characteristic.value)
            DataManager.shared.controlStatusUpdated(status: status)
        case HeaterServicesCharacteristics.waveTimeLimit.getUUID():
            let time = CharacteristicHandler.readUInt16Value(data: characteristic.value)
            DataManager.shared.waveTimeUpdated(waveTime: time)
        case HeaterServicesCharacteristics.initialOnTime.getUUID():
            let time = CharacteristicHandler.readUInt16Value(data: characteristic.value)
            DataManager.shared.initialOnTimeUpdated(initialOnTime: time)
        case HeaterServicesCharacteristics.tempUpperLimit.getUUID():
            let limit = CharacteristicHandler.readUInt8Value(data: characteristic.value)
            DataManager.shared.tempUpperLimitUpdated(tempUpperLimit: limit)
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
    
    func writeValue(_ characteristic: HeaterServicesCharacteristics, value: Int) {
        guard let characteristicValue = BLEManager.shared.getCharacteristics(with: characteristic.getValue()) else { return }
        switch characteristic {
        case .waveOnTime:
            CharacteristicHandler.writeUInt16Value(characteristicValue, UInt16(value))
        case .waveOffTime:
            CharacteristicHandler.writeUInt16Value(characteristicValue, UInt16(value))
        case .systemStats:
            break
        case .controlStatus:
            CharacteristicHandler.writeUInt8Value(characteristicValue, UInt8(value))
        case .waveTimeLimit:
            CharacteristicHandler.writeUInt16Value(characteristicValue, UInt16(value))
        case .initialOnTime:
            CharacteristicHandler.writeUInt16Value(characteristicValue, UInt16(value))
        case .tempUpperLimit:
            CharacteristicHandler.writeUInt8Value(characteristicValue, UInt8(value))
        case .batteryLevel:
            break
        case .deviceFirmware:
            break
        }
    }
}
