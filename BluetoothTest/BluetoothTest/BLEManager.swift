//
//  BLEManager.swift
//  BluetoothTest
//
//  Created by Mahnoor Khan on 15/10/2019.
//  Copyright © 2019 Mahnoor Khan. All rights reserved.
//

import Foundation
import CoreBluetooth

enum HeaterServices: String {
    case batteryService                 = "0x180F"
    case deviceInformationService       = "0x180A"
    case customService                  = "8c810001-4d6b-4d4c-9e14-cfc7db46018d"
    case deviceFirmwareUpdateService    = "8e400001-f315-4f60-9fb8-838830daea50"
    
    func getUUID() -> CBUUID {
        return CBUUID(string: self.rawValue)
    }
}

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
    
    func getUUID() -> CBUUID {
        return CBUUID(string: self.rawValue)
    }
}

class BLEManager: NSObject, BLECommunicationProtocol {
    private var deviceName              : String?
    static let shared                   = BLEManager()

    private var currentPeripheral       : CBPeripheral?
    private(set) var centralManager     : CBCentralManager?
    private(set) var allPeripherals     : [CBPeripheral]?
    
    private(set) var waveOnTime         : CBCharacteristic?
    private(set) var waveOffTime        : CBCharacteristic?
    private(set) var systemStats        : CBCharacteristic?
    private(set) var batteryLevel       : CBCharacteristic?
    private(set) var waveTimeLimit      : CBCharacteristic?
    private(set) var controlStatus      : CBCharacteristic?
    private(set) var initialOnTime      : CBCharacteristic?
    private(set) var deviceFirmware     : CBCharacteristic?
    private(set) var tempUpperLimit     : CBCharacteristic?
    
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
    
    private override init() {
        super.init()
        allPeripherals = []
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension BLEManager {
    func setDeviceName(deviceName: String) {
        self.deviceName = deviceName
    }
    
    func readValue(for characteristic: CBCharacteristic) {
        if characteristic.properties.contains(.read) {
            currentPeripheral?.readValue(for: characteristic)
        }
    }
    
    func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) {
        if characteristic.properties.contains(.write) {
            currentPeripheral?.writeValue(data, for: characteristic, type: type)
        }
    }
    
    func setNotification(_ enabled: Bool, for characteristic: CBCharacteristic) {
        if characteristic.properties.contains(.notify) {
            currentPeripheral?.setNotifyValue(enabled, for: characteristic)
        }
    }
    
    func connectPeripheral() {
        guard let bluetoothPeripheral = currentPeripheral else { return }
        centralManager?.connect(bluetoothPeripheral)
    }
    
    func disconnectCurrentPeripheral() {
        guard let bluetoothPeripheral = currentPeripheral else { return }
        centralManager?.cancelPeripheralConnection(bluetoothPeripheral)
        currentPeripheral = nil
        print("Disconnected from \(bluetoothPeripheral.name ?? "No name")")
    }
    
    func setCurrentPeripheral(_ peripheral: CBPeripheral) {
        currentPeripheral = peripheral
        currentPeripheral?.delegate = self
    }
}

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
}

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
            switch characteristic.uuid {
            case HeaterServicesCharacteristics.systemStats.getUUID():
                systemStats = characteristic
                setNotification(true, for: characteristic)
                readValue(for: characteristic)
            case HeaterServicesCharacteristics.initialOnTime.getUUID():
                initialOnTime = characteristic
                readValue(for: characteristic)
            case HeaterServicesCharacteristics.waveOnTime.getUUID():
                waveOnTime = characteristic
                readValue(for: characteristic)
            case HeaterServicesCharacteristics.waveOffTime.getUUID():
                waveOffTime = characteristic
                readValue(for: characteristic)
            case HeaterServicesCharacteristics.waveTimeLimit.getUUID():
                waveTimeLimit = characteristic
                readValue(for: characteristic)
            case HeaterServicesCharacteristics.tempUpperLimit.getUUID():
                tempUpperLimit = characteristic
                readValue(for: characteristic)
            case HeaterServicesCharacteristics.controlStatus.getUUID():
                controlStatus = characteristic
                setNotification(true, for: characteristic)
                readValue(for: characteristic)
            case HeaterServicesCharacteristics.batteryLevel.getUUID():
                batteryLevel = characteristic
                setNotification(true, for: characteristic)
                readValue(for: characteristic)
            case HeaterServicesCharacteristics.deviceFirmware.getUUID():
                deviceFirmware = characteristic
                setNotification(true, for: characteristic)
                //read not available
            default:
                print("Unhandled Characteristic UUID: \(characteristic.uuid)")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        characteristicUpdated(characteristic: characteristic)
    }
}
