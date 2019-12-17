//
//  BLEManager.swift
//  BluetoothTest
//
//  Created by Mahnoor Khan on 15/10/2019.
//  Copyright © 2019 Mahnoor Khan. All rights reserved.
//

import Foundation
import CoreBluetooth

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
    
    /// Function to reset Characteristic Listeners.
    func resetListners() {
        waveTimeChanged       = nil
        waveOnTimeChanged     = nil
        waveOffTimeChanged    = nil
        systemStatsChanged    = nil
        batteryLevelChanged   = nil
        controlStatusChanged  = nil
        initialOnTimeChanged  = nil
        tempUpperLimitChanged = nil
    }
}

// MARK: - Central Manager Delegate Functions.
extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            self.centralManager?.scanForPeripherals(withServices: nil)
        }
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
extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = currentPeripheral?.services else { return }
        for service in services {
            currentPeripheral?.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            switch characteristic.uuid {
            case HeaterServicesCharacteristics.systemStats.getUUID():
                BLEManager.shared.setCharacteristics(HeaterServicesCharacteristics.systemStats, characteristic)
                BLEManager.shared.setNotification(true, for: characteristic)
                BLEManager.shared.readValue(for: characteristic)
            case HeaterServicesCharacteristics.initialOnTime.getUUID():
                BLEManager.shared.setCharacteristics(HeaterServicesCharacteristics.initialOnTime, characteristic)
                BLEManager.shared.readValue(for: characteristic)
            case HeaterServicesCharacteristics.waveOnTime.getUUID():
                BLEManager.shared.setCharacteristics(HeaterServicesCharacteristics.waveOnTime, characteristic)
                BLEManager.shared.readValue(for: characteristic)
            case HeaterServicesCharacteristics.waveOffTime.getUUID():
                BLEManager.shared.setCharacteristics(HeaterServicesCharacteristics.waveOffTime, characteristic)
                BLEManager.shared.readValue(for: characteristic)
            case HeaterServicesCharacteristics.waveTimeLimit.getUUID():
                BLEManager.shared.setCharacteristics(HeaterServicesCharacteristics.waveTimeLimit, characteristic)
                BLEManager.shared.readValue(for: characteristic)
            case HeaterServicesCharacteristics.tempUpperLimit.getUUID():
                BLEManager.shared.setCharacteristics(HeaterServicesCharacteristics.tempUpperLimit, characteristic)
                BLEManager.shared.readValue(for: characteristic)
            case HeaterServicesCharacteristics.controlStatus.getUUID():
                BLEManager.shared.setCharacteristics(HeaterServicesCharacteristics.controlStatus, characteristic)
                BLEManager.shared.setNotification(true, for: characteristic)
                BLEManager.shared.readValue(for: characteristic)
            case HeaterServicesCharacteristics.batteryLevel.getUUID():
                BLEManager.shared.setCharacteristics(HeaterServicesCharacteristics.batteryLevel, characteristic)
                BLEManager.shared.setNotification(true, for: characteristic)
                BLEManager.shared.readValue(for: characteristic)
            case HeaterServicesCharacteristics.deviceFirmware.getUUID():
                BLEManager.shared.setCharacteristics(HeaterServicesCharacteristics.deviceFirmware, characteristic)
                BLEManager.shared.setNotification(true, for: characteristic)
            default:
                print("Unhandled Characteristic UUID: \(characteristic.uuid)")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case HeaterServicesCharacteristics.batteryLevel.getUUID():
            let level = CharacteristicReader.readUInt8Value(data: characteristic.value)
            batteryLevelChanged?(String(level))
        case HeaterServicesCharacteristics.waveOnTime.getUUID():
            let time = CharacteristicReader.readUInt16Value(data: characteristic.value)
            waveOnTimeChanged?(time)
        case HeaterServicesCharacteristics.waveOffTime.getUUID():
            let time = CharacteristicReader.readUInt16Value(data: characteristic.value)
            waveOffTimeChanged?(time)
        case HeaterServicesCharacteristics.systemStats.getUUID():
            let temperature = CharacteristicReader.readIntValue(data: characteristic.value)
            systemStatsChanged?(temperature)
        case HeaterServicesCharacteristics.controlStatus.getUUID():
            let status = CharacteristicReader.readUInt8Value(data: characteristic.value)
            controlStatusChanged?(status)
        case HeaterServicesCharacteristics.waveTimeLimit.getUUID():
            let time = CharacteristicReader.readUInt16Value(data: characteristic.value)
            waveTimeChanged?(time)
        case HeaterServicesCharacteristics.initialOnTime.getUUID():
            let time = CharacteristicReader.readUInt16Value(data: characteristic.value)
            initialOnTimeChanged?(time)
        case HeaterServicesCharacteristics.tempUpperLimit.getUUID():
            let limit = CharacteristicReader.readUInt8Value(data: characteristic.value)
            tempUpperLimitChanged?(limit)
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
}
