//
//  BLEManager.swift
//  BluetoothTest
//
//  Created by Mahnoor Khan on 15/10/2019.
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
    /// - Returns: CBUUID of the given characteristics.
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

class BLEManager: NSObject, BLECommunicationProtocol {
    //MARK:- Properties
    private var deviceName              : String?
    static let shared                   = BLEManager()

    private var currentPeripheral       : CBPeripheral?
    private(set) var centralManager     : CBCentralManager?
    private(set) var allPeripherals     : [CBPeripheral]?
    
    var waveTimeChanged                 : ((UInt16)->())? = nil
    var waveOnTimeChanged               : ((UInt16)->())? = nil
    var waveOffTimeChanged              : ((UInt16)->())? = nil
    var systemStatsChanged              : ((Int)->())?    = nil
    var batteryLevelChanged             : ((String)->())? = nil
    var controlStatusChanged            : ((UInt8)->())?  = nil
    var initialOnTimeChanged            : ((UInt16)->())? = nil
    var tempUpperLimitChanged           : ((UInt8)->())?  = nil
    
    var getConnectionStatus             : ((String)->())?
    var addNewPeripheralToList          : (([CBPeripheral])->())?
    
    private var characteristicMap       : [(type: HeaterServicesCharacteristics, object: CBCharacteristic?)] = []
    
    //MARK:- Initializer
    private override init() {
        super.init()
        allPeripherals = []
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension BLEManager {
    /// Function to set Device Name (Peripheral)
    ///
    /// - Parameter deviceName: name of the device to connect.
    func setDeviceName(deviceName: String) {
        self.deviceName = deviceName
    }
    
    /// Function to read value of a specific characteristic if it contains the read property.
    ///
    /// - Parameter characteristic: characteristic for reading its value.
    func readValue(for characteristic: CBCharacteristic) {
        if characteristic.properties.contains(.read) {
            currentPeripheral?.readValue(for: characteristic)
        }
    }
    
    /// Function to write value to a specific characteristic if it contains the write property.
    ///
    /// - Parameters:
    ///   - data: Data to write.
    ///   - characteristic: characteristic to write value.
    ///   - type: write value with or without response.
    func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) {
        if characteristic.properties.contains(.write) {
            currentPeripheral?.writeValue(data, for: characteristic, type: type)
        }
    }
    
    /// Function to write value to a specific characteristic if it contains the notify property.
    ///
    /// - Parameters:
    ///   - enabled: set notification true or false.
    ///   - characteristic: characteristic to set notification of.
    func setNotification(_ enabled: Bool, for characteristic: CBCharacteristic) {
        if characteristic.properties.contains(.notify) {
            currentPeripheral?.setNotifyValue(enabled, for: characteristic)
        }
    }
    
    /// Function to connect peripheral to phone.
    func connectPeripheral() {
        guard let bluetoothPeripheral = currentPeripheral else { return }
        centralManager?.connect(bluetoothPeripheral)
    }
    
    /// Function to disconnect function from phone.
    func disconnectCurrentPeripheral() {
        guard let bluetoothPeripheral = currentPeripheral else { return }
        centralManager?.cancelPeripheralConnection(bluetoothPeripheral)
    }
    
    /// Store reference of current connected peripheral.
    ///
    /// - Parameter peripheral: current peripheral.
    func setCurrentPeripheral(_ peripheral: CBPeripheral) {
        currentPeripheral = peripheral
        currentPeripheral?.delegate = self
    }
    
    /// Function to store reference of a service characteristic in an array.
    ///
    /// - Parameters:
    ///   - type: type of characteristic
    ///   - characteristic: the actual characteristic
    func setCharacteristics(_ type: HeaterServicesCharacteristics, _ characteristic: CBCharacteristic) {
        characteristicMap.append((type, characteristic))
    }
    
    /// Function to get characteristic from the stored references.
    ///
    /// - Parameter uuid: uuidString of the characteristic.
    /// - Returns: the actual characteristic.
    func getCharacteristics(with uuid: String) -> CBCharacteristic? {
        let characteristic = characteristicMap.first(where: {$0.type.getValue() == uuid })
        return characteristic?.object
    }
}

// MARK: - Central Manager Delegate Functions.
extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        centralManagerStateUpdated(central)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == deviceName && allPeripherals?.contains(peripheral) == false {
            allPeripherals?.append(peripheral)
            guard let peripherals = allPeripherals else { return}
            addNewPeripheralToList?(peripherals)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        getConnectionStatus?(peripheral.name ?? "No device")
        let serviceUUIDs = [HeaterServices.customService.getUUID(), HeaterServices.batteryService.getUUID(), HeaterServices.deviceFirmwareUpdateService.getUUID()]
        currentPeripheral?.discoverServices(serviceUUIDs)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        currentPeripheral = nil
        print("Disconnected from \(deviceName ?? "No name")")
    }
}

// MARK: - Peripheral Delegate Functions
extension BLEManager: CBPeripheralDelegate, BLEDataChangeProtocol {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = currentPeripheral?.services else { return }
        for service in services {
            currentPeripheral?.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            characteristicsDiscovered(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        characteristicUpdated(for: characteristic)
    }
}
