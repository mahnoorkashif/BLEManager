//
//  ServicesAndCharacteristics.swift
//  BluetoothTest
//
//  Created by Mahnoor Khan on 17/12/2019.
//  Copyright © 2019 Mahnoor Khan. All rights reserved.
//

import Foundation
import CoreBluetooth

/// Enum that contains UUID strings of services provided by the device.
///
/// - batteryService: UUID String of battery service.
/// - customService: UUID String of custom service provided by the device.
/// - deviceFirmwareUpdateService: UUID String of DFU service provided by the device.
enum HeaterServices: String {
    case batteryService                 = "0x180F"
    case customService                  = "8c810001-4d6b-4d4c-9e14-cfc7db46018d"
    case deviceFirmwareUpdateService    = "8e400001-f315-4f60-9fb8-838830daea50"
    
    /// Function to get CBUUID from given UUID String.
    ///
    /// - Returns: CBUUID of the given service.
    func getUUID() -> CBUUID {
        return CBUUID(string: self.rawValue)
    }
}

/// Enum that contains UUID strings of characteristics of the services provided by the device.
///
/// - batteryLevel: UUID String of battery service characteristic i.e. battery level.
/// - deviceFirmware: UUID String of custom service characteristic i.e. device firmware
/// - waveOnTime: UUID String of custom service characteristic i.e. waveOnTime
/// - waveOffTime: UUID String of custom service characteristic i.e. waveOffTime
/// - systemStats: UUID String of custom service characteristic i.e. systemStats
/// - controlStatus: UUID String of custom service characteristic i.e. controlStatus
/// - waveTimeLimit: UUID String of custom service characteristic i.e. waveTimeLimit
/// - initialOnTime: UUID String of custom service characteristic i.e. initialOnTime
/// - tempUpperLimit: UUID String of custom service characteristic i.e. tempUpperLimit
enum HeaterServicesCharacteristics: String {
    case batteryLevel       = "0x2A19"
    
    case deviceFirmware     = "8e400001-f315-4f60-9fb8-838830daea50"
    
    case waveOnTime         = "8c810006-4d6b-4d4c-9e14-cfc7db46018d"
    case waveOffTime        = "8c810007-4d6b-4d4c-9e14-cfc7db46018d"
    case systemStats        = "8c810003-4d6b-4d4c-9e14-cfc7db46018d"
    case controlStatus      = "8c810008-4d6b-4d4c-9e14-cfc7db46018d"
    case waveTimeLimit      = "8c810009-4d6b-4d4c-9e14-cfc7db46018d"
    case initialOnTime      = "8c810005-4d6b-4d4c-9e14-cfc7db46018d"
    case tempUpperLimit     = "8c810004-4d6b-4d4c-9e14-cfc7db46018d"
    
    /// Function to get UUID String of a charcateristics
    ///
    /// - Returns: CBUUID of the given characteristics.
    func getValue() -> String {
        return self.rawValue
    }
    
    /// Function to get CBUUID from given UUID String.
    ///
    /// - Returns: CBUUID of the given characteristics.
    func getUUID() -> CBUUID {
        return CBUUID(string: self.rawValue)
    }
}
