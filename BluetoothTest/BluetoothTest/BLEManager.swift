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
    
    func getValue() -> String {
        return self.rawValue
    }
}

class BLEManager: NSObject, BLECommunicationProtocol {
    private var deviceName              : String?
    static let shared                   = BLEManager()

    private var currentPeripheral       : CBPeripheral?
    private(set) var centralManager     : CBCentralManager?
    private(set) var allPeripherals     : [CBPeripheral]?
    
    private(set) var characteristics    : [CBCharacteristic]?
    
    private var characteristicMap  : [(type: HeaterServicesCharacteristics, object: CBCharacteristic?)] = []
    
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
        characteristics = []
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
    }
    
    func setCurrentPeripheral(_ peripheral: CBPeripheral) {
        currentPeripheral = peripheral
        currentPeripheral?.delegate = self
    }
    
    func setCharacteristics(_ type: HeaterServicesCharacteristics, _ characteristic: CBCharacteristic) {
        characteristicMap.append((type, characteristic))
    }
    
    func getCharacteristics(with uuid: String) -> CBCharacteristic? {
        let character = characteristicMap.first(where: {$0.type.getValue() == uuid })
        return character?.object
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
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        currentPeripheral = nil
        print("Disconnected from \(deviceName ?? "No name")")
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
            characteristicsDiscovered(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        characteristicUpdated(for: characteristic)
    }
}
