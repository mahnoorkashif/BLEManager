//
//  BLEDelegate.swift
//  BluetoothTest
//
//  Created by Mahnoor Khan on 17/10/2019.
//  Copyright © 2019 Mahnoor Khan. All rights reserved.
//

import Foundation

@objc protocol BLEDelegate: class {
    @objc optional func getBatteryLevel(_ batteryLevel: String)
    @objc optional func getSystemStats(_ currentTemperature: Int)
    @objc optional func getInitialOnTime(_ currentOnTime: UInt16)
    @objc optional func getWaveOnTime(_ currentWaveOnTime: UInt16)
    @objc optional func getWaveOffTime(_ currentWaveOffTime: UInt16)
    @objc optional func getWaveTimeLimit(_ currentWaveTimeLimit: UInt16)
    @objc optional func getTempUpperLimit(_ currentTempUpperLimit: UInt8)
    @objc optional func getControlStatus(_ currentControlStatus: UInt8)
}

extension BLEDelegate {
    func connectToPeripheral(at index: Int) {
        guard let newCurrent = BLEManager.shared.getAllPeripherals()?[index] else { return }
        BLEManager.shared.disconnectCurrentPeripheral()
        BLEManager.shared.setCurrentPeripheral(newCurrent)
        BLEManager.shared.connectPeripheral()
    }
    
    func disconnectPeripheral() {
        BLEManager.shared.disconnectCurrentPeripheral()
    }
    
    func readInitalOnTime() {
        guard let initialOnTime = BLEManager.shared.getInitialOnTimeCharacteristic() else { return }
        BLEManager.shared.readValue(for: initialOnTime)
    }
    
    func readWaveOnTime() {
        guard let waveOnTime = BLEManager.shared.getWaveOnTimeCharacteristic() else { return }
        BLEManager.shared.readValue(for: waveOnTime)
    }
    
    func readWaveOffTime() {
        guard let waveOffTime = BLEManager.shared.getWaveOffTimeCharacteristic() else { return }
        BLEManager.shared.readValue(for: waveOffTime)
    }
    
    func readWaveTimeLimit() {
        guard let waveTimeLimit = BLEManager.shared.getWaveTimeLimitCharacteristic() else { return }
        BLEManager.shared.readValue(for: waveTimeLimit)
    }
    
    func readTempUpperLimit() {
        guard let tempUpperLimit = BLEManager.shared.getTempUpperLimitCharacteristic() else { return }
        BLEManager.shared.readValue(for: tempUpperLimit)
    }
    
    func readControlStatus() {
        guard let controlStatus = BLEManager.shared.getControlStatusCharacteristic() else { return }
        BLEManager.shared.readValue(for: controlStatus)
    }
    
    func writeInitalOnTime(_ value: UInt16) {
        guard let initialOnTime = BLEManager.shared.getInitialOnTimeCharacteristic() else { return }
        let data = DataConverter.getDataFromUInt16(value)
        BLEManager.shared.writeValue(data, for: initialOnTime, type: .withoutResponse)
    }
    
    func writeWaveOnTime(_ value: UInt16) {
        guard let waveOnTime = BLEManager.shared.getWaveOnTimeCharacteristic() else { return }
        let data = DataConverter.getDataFromUInt16(value)
        BLEManager.shared.writeValue(data, for: waveOnTime, type: .withoutResponse)
    }
    
    func writeWaveOffTime(_ value: UInt16) {
        guard let waveOffTime = BLEManager.shared.getWaveOffTimeCharacteristic() else { return }
        let data = DataConverter.getDataFromUInt16(value)
        BLEManager.shared.writeValue(data, for: waveOffTime, type: .withoutResponse)
    }
    
    func writeWaveTimeLimit(_ value: UInt16) {
        guard let waveTimeLimit = BLEManager.shared.getWaveTimeLimitCharacteristic() else { return }
        let data = DataConverter.getDataFromUInt16(value)
        BLEManager.shared.writeValue(data, for: waveTimeLimit, type: .withoutResponse)
    }
    
    func writeTempUpperLimit(_ value: UInt8) {
        guard let tempUpperLimit = BLEManager.shared.getTempUpperLimitCharacteristic() else { return }
        let data = DataConverter.getDataFromUInt8(value)
        BLEManager.shared.writeValue(data, for: tempUpperLimit, type: .withoutResponse)
    }
    
    func writeControlStatus(_ value: UInt8) {
        guard let controlStatus = BLEManager.shared.getControlStatusCharacteristic() else { return }
        let data = DataConverter.getDataFromUInt8(value)
        BLEManager.shared.writeValue(data, for: controlStatus, type: .withoutResponse)
    }
}
