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
        CharacteristicWriter.writeCharacteristic(characteristic, value)
    }
}
