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
    case customService                  = "8c810001-4d6b-4d4c-9e14-cfc7db46018d"
    case batteryService                 = "0x180F"
    case deviceFirmwareUpdateService    = "8e400001-f315-4f60-9fb8-838830daea50"
    case deviceInformationService       = "0x180A"
}

enum HeaterServicesCharacteristics: String {
    case systemStats    = "8c810003-4d6b-4d4c-9e14-cfc7db46018d"
    case initialOnTime  = "8c810005-4d6b-4d4c-9e14-cfc7db46018d"
    case waveOnTime     = "8c810006-4d6b-4d4c-9e14-cfc7db46018d"
    case waveOffTime    = "8c810007-4d6b-4d4c-9e14-cfc7db46018d"
    case waveTimeLimit  = "8c810009-4d6b-4d4c-9e14-cfc7db46018d"
    case tempUpperLimit = "8c810004-4d6b-4d4c-9e14-cfc7db46018d"
    case controlStatus  = "8c810008-4d6b-4d4c-9e14-cfc7db46018d"
    
    case batteryLevel   = "0x2A19"
    
    case deviceFirmware = "8e400001-f315-4f60-9fb8-838830daea50"
}

class BLEManager: NSObject {
    
    var delegate                        : BLEDelegate?
    static let shared                   = BLEManager()
    private var deviceName              : String?
    private var currentPeripheral       : CBPeripheral?
    private var allPeripherals          : [CBPeripheral] = []
    private var centralManager          : CBCentralManager?
    
    var getConnectionStatus             : ((String)->())?
    var reloadTableView                 : (([CBPeripheral])->())?
    
    private var systemStats             : CBCharacteristic?
    private var initialOnTime           : CBCharacteristic?
    private var waveOnTime              : CBCharacteristic?
    private var waveOffTime             : CBCharacteristic?
    private var waveTimeLimit           : CBCharacteristic?
    private var tempUpperLimit          : CBCharacteristic?
    private var controlStatus           : CBCharacteristic?
    private var batteryLevel            : CBCharacteristic?
    private var deviceFirmware          : CBCharacteristic?
    
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension BLEManager {
    func setDeviceName(deviceName: String) {
        self.deviceName = deviceName
    }
    
    func getUUIDs(_ ids: [String]) -> [CBUUID] {
        var UUIDs: [CBUUID] = []
        for id in ids {
            UUIDs.append(CBUUID(string: id))
        }
        return UUIDs
    }
    
    func setNotification(_ enabled: Bool, for characteristic: CBCharacteristic) {
        currentPeripheral?.setNotifyValue(enabled, for: characteristic)
    }
    
    func getCurrentPeripheral() -> CBPeripheral? {
        return currentPeripheral
    }
}

extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            centralManager?.scanForPeripherals(withServices: nil)
        @unknown default:
            print("central.state is .default")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !allPeripherals.contains(peripheral) {
            allPeripherals.append(peripheral)
            reloadTableView?(allPeripherals)
        }
        if peripheral.name == deviceName {
            
        }
        
        if peripheral.name == deviceName {
            currentPeripheral = peripheral
            currentPeripheral?.delegate = self
//            centralManager?.stopScan()
            guard let bluetoothPeripheral = currentPeripheral else { return }
            centralManager?.connect(bluetoothPeripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        getConnectionStatus?("Connected to \(peripheral.name ?? "no deivce").")
        let ids = [HeaterServices.customService.rawValue, HeaterServices.batteryService.rawValue, HeaterServices.deviceFirmwareUpdateService.rawValue]
        let servicesUUIDs = getUUIDs(ids)
        currentPeripheral?.discoverServices(servicesUUIDs)
    }
}

extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print(peripheral)
        guard let services = currentPeripheral?.services else { return }
        for service in services {
            print(service)
            currentPeripheral?.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            switch characteristic.uuid {
            case getUUIDs([HeaterServicesCharacteristics.systemStats.rawValue]).first:
                systemStats = characteristic
                setNotification(true, for: characteristic)
                if characteristic.properties.contains(.read) {
                    currentPeripheral?.readValue(for: characteristic)
                }
            case getUUIDs([HeaterServicesCharacteristics.initialOnTime.rawValue]).first:
                initialOnTime = characteristic
                if characteristic.properties.contains(.read) {
                    currentPeripheral?.readValue(for: characteristic)
                }
            case getUUIDs([HeaterServicesCharacteristics.waveOnTime.rawValue]).first:
                waveOnTime = characteristic
                if characteristic.properties.contains(.read) {
                    currentPeripheral?.readValue(for: characteristic)
                }
            case getUUIDs([HeaterServicesCharacteristics.waveOffTime.rawValue]).first:
                waveOffTime = characteristic
                if characteristic.properties.contains(.read) {
                    currentPeripheral?.readValue(for: characteristic)
                }
            case getUUIDs([HeaterServicesCharacteristics.waveTimeLimit.rawValue]).first:
                waveTimeLimit = characteristic
                if characteristic.properties.contains(.read) {
                    currentPeripheral?.readValue(for: characteristic)
                }
            case getUUIDs([HeaterServicesCharacteristics.tempUpperLimit.rawValue]).first:
                tempUpperLimit = characteristic
                if characteristic.properties.contains(.read) {
                    currentPeripheral?.readValue(for: characteristic)
                }
            case getUUIDs([HeaterServicesCharacteristics.controlStatus.rawValue]).first:
                controlStatus = characteristic
                setNotification(true, for: characteristic)
                if characteristic.properties.contains(.read) {
                    currentPeripheral?.readValue(for: characteristic)
                }
            case getUUIDs([HeaterServicesCharacteristics.batteryLevel.rawValue]).first:
                batteryLevel = characteristic
                setNotification(true, for: characteristic)
                if characteristic.properties.contains(.read) {
                    currentPeripheral?.readValue(for: characteristic)
                }
            case getUUIDs([HeaterServicesCharacteristics.deviceFirmware.rawValue]).first:
                deviceFirmware = characteristic
                setNotification(true, for: characteristic)
                //read not available
            default:
                break
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case getUUIDs([HeaterServicesCharacteristics.systemStats.rawValue]).first:
            let temperature = systemStats(from: characteristic)
            delegate?.getInitialSystemStats?(temperature)
        case getUUIDs([HeaterServicesCharacteristics.initialOnTime.rawValue]).first:
            let initOnTime = getUInt16Characteristics(from: characteristic)
            delegate?.getInitialOnTime?(initOnTime)
        case getUUIDs([HeaterServicesCharacteristics.waveOnTime.rawValue]).first:
            let waveOn = getUInt16Characteristics(from: characteristic)
            delegate?.getWaveOnTime?(waveOn)
        case getUUIDs([HeaterServicesCharacteristics.waveOffTime.rawValue]).first:
            let waveOff = getUInt16Characteristics(from: characteristic)
            delegate?.getWaveOffTime?(waveOff)
        case getUUIDs([HeaterServicesCharacteristics.waveTimeLimit.rawValue]).first:
            let waveLimit = getUInt16Characteristics(from: characteristic)
            delegate?.getWaveTimeLimit?(waveLimit)
        case getUUIDs([HeaterServicesCharacteristics.tempUpperLimit.rawValue]).first:
            let tempUpper = getUInt8Characteristics(from: characteristic)
            delegate?.getTempUpperLimit?(tempUpper)
        case getUUIDs([HeaterServicesCharacteristics.controlStatus.rawValue]).first:
            let status = getUInt8Characteristics(from: characteristic)
            delegate?.getControlStatus?(status)
        case getUUIDs([HeaterServicesCharacteristics.batteryLevel.rawValue]).first:
            let level = batteryLevel(from: characteristic)
            delegate?.getInitialBatteryLevel?(level)
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
}

extension BLEManager {
    func systemStats(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value
            else { return 0 }
        let currentTemperature = CharacteristicReader.readIntValue(data: characteristicData)
        return currentTemperature
    }
    
    func getUInt8Characteristics(from characteristic: CBCharacteristic) -> UInt8 {
        guard let characteristicData = characteristic.value else { return 0 }
        let currentInitialOnTime = CharacteristicReader.readUInt8Value(data: characteristicData)
        return currentInitialOnTime
    }
    
    func getUInt16Characteristics(from characteristic: CBCharacteristic) -> UInt16 {
        guard let characteristicData = characteristic.value else { return 0 }
        let currentInitialOnTime = CharacteristicReader.readUInt16Value(data: characteristicData)
        return currentInitialOnTime
    }
    
    func batteryLevel(from characteristic: CBCharacteristic) -> String {
        guard let characteristicData = characteristic.value else { return  "Error" }
        let currentBatteryLevel = CharacteristicReader.readUInt8Value(data: characteristicData)
        return "Battery Percentage: \(Int(currentBatteryLevel))"
    }
}
