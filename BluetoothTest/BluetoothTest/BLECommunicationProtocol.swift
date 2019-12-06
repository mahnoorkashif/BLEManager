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
    /// Function to connect to a particular peripheral in the list.
    ///
    /// - Parameter index: index of the peripheral to connect.
    func connectToPeripheral(at index: Int) {
        guard let newCurrent = BLEManager.shared.allPeripherals?[index] else { return }
        BLEManager.shared.disconnectCurrentPeripheral()
        BLEManager.shared.setCurrentPeripheral(newCurrent)
        BLEManager.shared.connectPeripheral()
    }
    
    /// Function to discoonect the current connected peripheral.
    func disconnectPeripheral() {
        BLEManager.shared.disconnectCurrentPeripheral()
    }
    
    /// Function to read the value of a charcateristic.
    ///
    /// - Parameter characteristic: uuid string of the charcateristic.
    func readCharacteristicValue(_ characteristic: HeaterServicesCharacteristics) {
        guard let characteristic = BLEManager.shared.getCharacteristics(with: characteristic.getValue()) else { return }
        BLEManager.shared.readValue(for: characteristic)
    }
    
    func writeCharacteristicValue(_ characteristic: HeaterServicesCharacteristics, _ value: Int) {
//        guard let characteristicValue = BLEManager.shared.getCharacteristics(with: characteristic.getValue()) else { return }
        CharacteristicWriter.writeCharacteristic(characteristic, value)
    }
    
    /// Fucntion to write value of a characteristic whose datatype is UInt8
    ///
    /// - Parameters:
    ///   - characteristic: uuid string of the characteristic.
    ///   - value: value to write
    func writeUInt8Value(_ characteristic: HeaterServicesCharacteristics, _ value: UInt8) {
        guard let characteristic = BLEManager.shared.getCharacteristics(with: characteristic.getValue()) else { return }
        let data = DataConverter.getDataFromUInt8(value)
        BLEManager.shared.writeValue(data, for: characteristic, type: .withoutResponse)
    }
//
//    /// Fucntion to write value of a characteristic whose datatype is UInt16
//    ///
//    /// - Parameters:
//    ///   - characteristic: uuid string of the characteristic.
//    ///   - value: value to write
//    func writeUInt16Value(_ characteristic: HeaterServicesCharacteristics, _ value: UInt16) {
//        guard let characteristic = BLEManager.shared.getCharacteristics(with: characteristic.getValue()) else { return }
//        let data = DataConverter.getDataFromUInt16(value)
//        BLEManager.shared.writeValue(data, for: characteristic, type: .withoutResponse)
//    }
}
