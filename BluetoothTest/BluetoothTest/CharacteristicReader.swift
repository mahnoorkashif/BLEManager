//
//  CharacteristicReader.swift
//  BluetoothTest
//
//  Created by Mahnoor Khan on 15/10/2019.
//  Copyright © 2019 Mahnoor Khan. All rights reserved.
//

import Foundation

struct CharacteristicReader {
    static func readUInt8Value(data aData :Data?) -> UInt8 {
        var array = UnsafeMutablePointer<UInt8>(OpaquePointer(((aData as NSData?)?.bytes)!))
        return self.readUInt8Value(ptr: &array)
    }
    
    static func readIntValue(data aData :Data?) -> Int {
        var int32Val : UInt32 = 0
        let stringInt = String.init(data: aData!, encoding: String.Encoding.utf8)!
        for element in stringInt.unicodeScalars {
            int32Val = element.value              // UInt32
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
