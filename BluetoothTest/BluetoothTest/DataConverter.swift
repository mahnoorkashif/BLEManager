//
//  DataConverter.swift
//  BluetoothTest
//
//  Created by Mahnoor Khan on 18/10/2019.
//  Copyright © 2019 Mahnoor Khan. All rights reserved.
//

import Foundation

struct DataConverter {
    static func getDataFromUIInt16(_ value: UInt16) -> Data {
        var val = value
        let data = Data(bytes: UnsafePointer(&val), count: MemoryLayout.size(ofValue: value))
        return data
    }
}
