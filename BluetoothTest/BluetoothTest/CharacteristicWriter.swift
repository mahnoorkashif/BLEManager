//
//  CharacteristicWriter.swift
//  BluetoothTest
//
//  Created by Mahnoor Khan on 05/12/2019.
//  Copyright © 2019 Mahnoor Khan. All rights reserved.
//

import Foundation
import CoreBluetooth

struct CharacteristicWriter {
    static func writeCharacteristic(_ characteristic: HeaterServicesCharacteristics, _ value: Int) {
        guard let characteristicValue = BLEManager.shared.getCharacteristics(with: characteristic.getValue()) else { return }
        switch characteristic {
        case .batteryLevel:
            break
        case .deviceFirmware:
            break
        case .waveOnTime:
            writeUInt16Value(characteristicValue, UInt16(value))
        case .waveOffTime:
            writeUInt16Value(characteristicValue, UInt16(value))
        case .systemStats:
            break
        case .controlStatus:
            writeUInt8Value(characteristicValue, UInt8(value))
        case .waveTimeLimit:
            writeUInt16Value(characteristicValue, UInt16(value))
        case .initialOnTime:
            writeUInt16Value(characteristicValue, UInt16(value))
        case .tempUpperLimit:
            writeUInt8Value(characteristicValue, UInt8(value))
        default:
            break
        }
    }
    
    /// Fucntion to write value of a characteristic whose datatype is UInt8
    ///
    /// - Parameters:
    ///   - characteristic: uuid string of the characteristic.
    ///   - value: value to write
    static func writeUInt8Value(_ characteristic: CBCharacteristic, _ value: UInt8) {
        let data = DataConverter.getDataFromUInt8(value)
        BLEManager.shared.writeValue(data, for: characteristic, type: .withoutResponse)
    }
    
    /// Fucntion to write value of a characteristic whose datatype is UInt16
    ///
    /// - Parameters:
    ///   - characteristic: uuid string of the characteristic.
    ///   - value: value to write
    static func writeUInt16Value(_ characteristic: CBCharacteristic, _ value: UInt16) {
        let data = DataConverter.getDataFromUInt16(value)
        BLEManager.shared.writeValue(data, for: characteristic, type: .withoutResponse)
    }
}
