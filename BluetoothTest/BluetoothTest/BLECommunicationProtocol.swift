//
//  BLECommunicationProtocol.swift
//  BluetoothTest
//
//  Created by Mahnoor Khan on 18/10/2019.
//  Copyright © 2019 Mahnoor Khan. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BLECommunicationProtocol {}

extension BLECommunicationProtocol where Self: BLEManager {
    func connectToPeripheral(at index: Int) {
        guard let newCurrent = BLEManager.shared.allPeripherals?[index] else { return }
        BLEManager.shared.disconnectCurrentPeripheral()
        BLEManager.shared.setCurrentPeripheral(newCurrent)
        BLEManager.shared.connectPeripheral()
    }
    
    func disconnectPeripheral() {
        BLEManager.shared.disconnectCurrentPeripheral()
    }
    
    func readInitalOnTime() {
        guard let initialOnTime = BLEManager.shared.getCharacteristics(with: HeaterServicesCharacteristics.initialOnTime.getValue()) else { return }
        BLEManager.shared.readValue(for: initialOnTime)
    }
    
    func readWaveOnTime() {
        guard let waveOnTime = BLEManager.shared.getCharacteristics(with: HeaterServicesCharacteristics.waveOnTime.getValue()) else { return }
        BLEManager.shared.readValue(for: waveOnTime)
    }
    
    func readWaveOffTime() {
        guard let waveOffTime = BLEManager.shared.getCharacteristics(with: HeaterServicesCharacteristics.waveOffTime.getValue()) else { return }
        BLEManager.shared.readValue(for: waveOffTime)
    }
    
    func readWaveTimeLimit() {
        guard let waveTimeLimit = BLEManager.shared.getCharacteristics(with: HeaterServicesCharacteristics.waveTimeLimit.getValue()) else { return }
        BLEManager.shared.readValue(for: waveTimeLimit)
    }
    
    func readTempUpperLimit() {
        guard let tempUpperLimit = BLEManager.shared.getCharacteristics(with: HeaterServicesCharacteristics.tempUpperLimit.getValue()) else { return }
        BLEManager.shared.readValue(for: tempUpperLimit)
    }
    
    func readControlStatus() {
        guard let controlStatus = BLEManager.shared.getCharacteristics(with: HeaterServicesCharacteristics.controlStatus.getValue()) else { return }
        BLEManager.shared.readValue(for: controlStatus)
    }
    
    func writeInitalOnTime(_ value: UInt16) {
        guard let initialOnTime = BLEManager.shared.getCharacteristics(with: HeaterServicesCharacteristics.initialOnTime.getValue())
            else {
                return }
        let data = DataConverter.getDataFromUInt16(value)
        BLEManager.shared.writeValue(data, for: initialOnTime, type: .withoutResponse)
    }
    
    func writeWaveOnTime(_ value: UInt16) {
        guard let waveOnTime = BLEManager.shared.getCharacteristics(with: HeaterServicesCharacteristics.waveOnTime.getValue()) else { return }
        let data = DataConverter.getDataFromUInt16(value)
        BLEManager.shared.writeValue(data, for: waveOnTime, type: .withoutResponse)
    }
    
    func writeWaveOffTime(_ value: UInt16) {
        guard let waveOffTime = BLEManager.shared.getCharacteristics(with: HeaterServicesCharacteristics.waveOffTime.getValue()) else { return }
        let data = DataConverter.getDataFromUInt16(value)
        BLEManager.shared.writeValue(data, for: waveOffTime, type: .withoutResponse)
    }
    
    func writeWaveTimeLimit(_ value: UInt16) {
        guard let waveTimeLimit = BLEManager.shared.getCharacteristics(with: HeaterServicesCharacteristics.waveTimeLimit.getValue()) else { return }
        let data = DataConverter.getDataFromUInt16(value)
        BLEManager.shared.writeValue(data, for: waveTimeLimit, type: .withoutResponse)
    }
    
    func writeTempUpperLimit(_ value: UInt8) {
        guard let tempUpperLimit = BLEManager.shared.getCharacteristics(with: HeaterServicesCharacteristics.tempUpperLimit.getValue()) else { return }
        let data = DataConverter.getDataFromUInt8(value)
        BLEManager.shared.writeValue(data, for: tempUpperLimit, type: .withoutResponse)
    }
    
    func writeControlStatus(_ value: UInt8) {
        guard let controlStatus = BLEManager.shared.getCharacteristics(with: HeaterServicesCharacteristics.controlStatus.getValue()) else { return }
        let data = DataConverter.getDataFromUInt8(value)
        BLEManager.shared.writeValue(data, for: controlStatus, type: .withoutResponse)
    }
}
