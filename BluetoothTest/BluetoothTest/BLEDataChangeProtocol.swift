//
//  BLEDelegate.swift
//  BluetoothTest
//
//  Created by Mahnoor Khan on 17/10/2019.
//  Copyright © 2019 Mahnoor Khan. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BLEDataChangeProtocol  : class {
    var waveTimeChanged         : ((UInt16)->())?   { get set }
    var waveOnTimeChanged       : ((UInt16)->())?   { get set }
    var waveOffTimeChanged      : ((UInt16)->())?   { get set }
    var systemStatsChanged      : ((Int)->())?      { get set }
    var batteryLevelChanged     : ((String)->())?   { get set }
    var controlStatusChanged    : ((UInt8)->())?    { get set }
    var initialOnTimeChanged    : ((UInt16)->())?   { get set }
    var tempUpperLimitChanged   : ((UInt8)->())?    { get set }
}

extension BLEDataChangeProtocol {
    /// Function to check the state of central manager i.e. the status of phone bluetooth.
    ///
    /// - Parameter central: the central manager
    func centralManagerStateUpdated(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            BLEManager.shared.centralManager?.scanForPeripherals(withServices: nil)
        @unknown default:
            print("central.state is .default")
        }
    }
    
    /// Function to read the updated or current value of the characteristic.
    ///
    /// - Parameter characteristic: the characteristic.
    func characteristicUpdated(for characteristic: CBCharacteristic) {
        switch characteristic.uuid {
        case HeaterServicesCharacteristics.batteryLevel.getUUID():
            let level = getUInt8Characteristic(from: characteristic)
            batteryLevelChanged?(String(level))
        case HeaterServicesCharacteristics.waveOnTime.getUUID():
            let time = getUInt16Characteristic(from: characteristic)
            waveOnTimeChanged?(time)
        case HeaterServicesCharacteristics.waveOffTime.getUUID():
            let time = getUInt16Characteristic(from: characteristic)
            waveOffTimeChanged?(time)
        case HeaterServicesCharacteristics.systemStats.getUUID():
            let temperature = getIntCharacteristic(from: characteristic)
            systemStatsChanged?(temperature)
        case HeaterServicesCharacteristics.controlStatus.getUUID():
            let status = getUInt8Characteristic(from: characteristic)
            controlStatusChanged?(status)
        case HeaterServicesCharacteristics.waveTimeLimit.getUUID():
            let time = getUInt16Characteristic(from: characteristic)
            waveTimeChanged?(time)
        case HeaterServicesCharacteristics.initialOnTime.getUUID():
            let time = getUInt16Characteristic(from: characteristic)
            initialOnTimeChanged?(time)
        case HeaterServicesCharacteristics.tempUpperLimit.getUUID():
            let limit = getUInt8Characteristic(from: characteristic)
            tempUpperLimitChanged?(limit)
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
    /// Function to store characteristic reference when discovered, setting its notification property true if they contain it and read its value.
    ///
    /// - Parameter characteristic: the characteristic.
    func characteristicsDiscovered(for characteristic: CBCharacteristic) {
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
        case HeaterServicesCharacteristics.batteryLevel.getUUID():
            BLEManager.shared.setCharacteristics(HeaterServicesCharacteristics.batteryLevel, characteristic)
            BLEManager.shared.setNotification(true, for: characteristic)
            BLEManager.shared.readValue(for: characteristic)
        case HeaterServicesCharacteristics.deviceFirmware.getUUID():
            BLEManager.shared.setCharacteristics(HeaterServicesCharacteristics.deviceFirmware, characteristic)
            BLEManager.shared.setNotification(true, for: characteristic)
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
    /// Function to reset Characteristic Listeners.
    func resetListners() {
        waveTimeChanged       = nil
        waveOnTimeChanged     = nil
        waveOffTimeChanged    = nil
        systemStatsChanged    = nil
        batteryLevelChanged   = nil
        controlStatusChanged  = nil
        initialOnTimeChanged  = nil
        tempUpperLimitChanged = nil
    }
}


extension BLEDataChangeProtocol {
    /// Function to convert and read value of characteristics whose data type is Int.
    ///
    /// - Parameter characteristic: the characteristics.
    /// - Returns: value of the characteristic.
    func getIntCharacteristic(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return 0 }
        let currentTemperature = CharacteristicReader.readIntValue(data: characteristicData)
        return currentTemperature
    }
    
    /// Function to convert and read value of characteristics whose data type is UInt8.
    ///
    /// - Parameter characteristic: the characteristic.
    /// - Returns: value of the characteristic.
    func getUInt8Characteristic(from characteristic: CBCharacteristic) -> UInt8 {
        guard let characteristicData = characteristic.value else { return 0 }
        let currentInitialOnTime = CharacteristicReader.readUInt8Value(data: characteristicData)
        return currentInitialOnTime
    }
    
    /// Function to convert and read value of characteristics whose data type is UInt6.
    ///
    /// - Parameter characteristic: the characteristic.
    /// - Returns: value of the characteristic.
    func getUInt16Characteristic(from characteristic: CBCharacteristic) -> UInt16 {
        guard let characteristicData = characteristic.value else { return 0 }
        let currentInitialOnTime = CharacteristicReader.readUInt16Value(data: characteristicData)
        return currentInitialOnTime
    }
}
