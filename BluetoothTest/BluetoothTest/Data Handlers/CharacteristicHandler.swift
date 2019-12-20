
//
//  CharacteristicHandler.swift
//  BluetoothTest
//
//  Created by Mahnoor Khan on 05/12/2019.
//  Copyright © 2019 Mahnoor Khan. All rights reserved.
//
import Foundation
import CoreBluetooth

struct CharacteristicHandler {}

extension CharacteristicHandler {
    static func writeCharacteristic(_ characteristic: HeaterServicesCharacteristics, _ value: Int) {
        guard let characteristicValue = BLEManager.shared.getCharacteristics(with: characteristic.getValue()) else { return }
        if characteristicValue.service.uuid == HeaterServices.customService.getUUID() {
            CustomServiceHandler.shared.writeValue(characteristic, value: value)
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

extension CharacteristicHandler {
    static func readUInt8Value(data aData :Data?) -> UInt8 {
        var array = UnsafeMutablePointer<UInt8>(OpaquePointer(((aData as NSData?)?.bytes)!))
        return self.readUInt8Value(ptr: &array)
    }
    
    static func readIntValue(data aData :Data?) -> Int {
        var int32Val : UInt32 = 0
        let stringInt = String.init(data: aData!, encoding: String.Encoding.utf8)!
        for element in stringInt.unicodeScalars {
            int32Val = element.value
        }
        let int = Int(int32Val)
        return int
    }
    
    static func readUInt16Value(data aData :Data?) -> UInt16 {
        var array = UnsafeMutablePointer<UInt8>(mutating: (aData! as NSData).bytes.bindMemory(to: UInt8.self, capacity: aData!.count))
        return self.readUInt16Value(ptr: &array)
    }
    
    static func readUInt8Value(ptr aPointer : inout UnsafeMutablePointer<UInt8>) -> UInt8 {
        let val = aPointer.pointee
        aPointer = aPointer.successor()
        return val
    }
    
    static func readUInt16Value(ptr aPointer : inout UnsafeMutablePointer<UInt8>) -> UInt16 {
        let anUInt16Pointer = UnsafeMutablePointer<UInt16>(OpaquePointer(aPointer))
        let val = CFSwapInt16LittleToHost(anUInt16Pointer.pointee)
        aPointer = aPointer.advanced(by: 2)
        return val
    }
}
