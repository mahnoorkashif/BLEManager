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
    
    func readCharacteristicValue(_ characteristic: HeaterServicesCharacteristics) {
        guard let characteristic = BLEManager.shared.getCharacteristics(with: characteristic.getValue()) else { return }
        BLEManager.shared.readValue(for: characteristic)
    }
    
    func writeUInt16Value(_ characteristic: HeaterServicesCharacteristics, _ value: UInt16) {
        guard let characteristic = BLEManager.shared.getCharacteristics(with: characteristic.getValue()) else { return }
        let data = DataConverter.getDataFromUInt16(value)
        BLEManager.shared.writeValue(data, for: characteristic, type: .withoutResponse)
    }
    
    func writeUInt8Value(_ characteristic: HeaterServicesCharacteristics, _ value: UInt8) {
        guard let characteristic = BLEManager.shared.getCharacteristics(with: characteristic.getValue()) else { return }
        let data = DataConverter.getDataFromUInt8(value)
        BLEManager.shared.writeValue(data, for: characteristic, type: .withoutResponse)
    }
}
