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
    
    func writeWaveOnTime(_ value: UInt16) {
        guard let waveOnTime = BLEManager.shared.getWaveOnTimeCharacteristic() else { return }
        let data = DataConverter.getDataFromUIInt16(value)
        BLEManager.shared.writeValue(data, for: waveOnTime, type: .withResponse)
    }
}
