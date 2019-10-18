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
    
    func getUUID() -> CBUUID {
        return CBUUID(string: self.rawValue)
    }
}

enum HeaterServicesCharacteristics: String {
    case waveOnTime         = "8c810006-4d6b-4d4c-9e14-cfc7db46018d"
    case waveOffTime        = "8c810007-4d6b-4d4c-9e14-cfc7db46018d"
    case systemStats        = "8c810003-4d6b-4d4c-9e14-cfc7db46018d"
    case controlStatus      = "8c810008-4d6b-4d4c-9e14-cfc7db46018d"
    case waveTimeLimit      = "8c810009-4d6b-4d4c-9e14-cfc7db46018d"
    case initialOnTime      = "8c810005-4d6b-4d4c-9e14-cfc7db46018d"
    case tempUpperLimit     = "8c810004-4d6b-4d4c-9e14-cfc7db46018d"
    
    case batteryLevel       = "0x2A19"
    
    case deviceFirmware     = "8e400001-f315-4f60-9fb8-838830daea50"
    
    func getUUID() -> CBUUID {
        return CBUUID(string: self.rawValue)
    }
}

class BLEManager: NSObject {
    private var deviceName              : String?
    static let shared                   = BLEManager()
    weak var delegate                   : BLEDelegate?
    private var currentPeripheral       : CBPeripheral?
    private var centralManager          : CBCentralManager?
    private var allPeripherals          : [CBPeripheral] = []
    
    private var waveOnTime              : CBCharacteristic?
    private var waveOffTime             : CBCharacteristic?
    private var systemStats             : CBCharacteristic?
    private var batteryLevel            : CBCharacteristic?
    private var waveTimeLimit           : CBCharacteristic?
    private var controlStatus           : CBCharacteristic?
    private var initialOnTime           : CBCharacteristic?
    private var deviceFirmware          : CBCharacteristic?
    private var tempUpperLimit          : CBCharacteristic?
    
    var getConnectionStatus             : ((String)->())?
    var reloadTableView                 : (([CBPeripheral])->())?
    
    private override init() {
        super.init()
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
    
    func getCurrentPeripheral() -> CBPeripheral? {
        return currentPeripheral
    }
    
    func getCentralManager() -> CBCentralManager? {
        return centralManager
    }
    
    func getAllPeripherals() -> [CBPeripheral]? {
        return allPeripherals
    }
    
    func getSystemStatsCharacteristic() -> CBCharacteristic? {
        return systemStats
    }
    
    func getInitialOnTimeCharacteristic() -> CBCharacteristic? {
        return initialOnTime
    }
    
    func getWaveOnTimeCharacteristic() -> CBCharacteristic? {
        return waveOnTime
    }
    
    func getWaveOffTimeCharacteristic() -> CBCharacteristic? {
        return waveOffTime
    }
    
    func getWaveTimeLimitCharacteristic() -> CBCharacteristic? {
        return waveTimeLimit
    }
    
    func getTempUpperLimitCharacteristic() -> CBCharacteristic? {
        return tempUpperLimit
    }
    
    func getControlStatusCharacteristic() -> CBCharacteristic? {
        return controlStatus
    }
    
    func getBatteryLevelCharacteristic() -> CBCharacteristic? {
        return batteryLevel
    }
    
    func getDeviceFirmwareCharacteristic() -> CBCharacteristic? {
        return deviceFirmware
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
        if peripheral.name == deviceName && !allPeripherals.contains(peripheral) {
            allPeripherals.append(peripheral)
            reloadTableView?(allPeripherals)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        getConnectionStatus?(peripheral.name ?? "No device")
        let serviceUUIDs = [HeaterServices.customService.getUUID(), HeaterServices.batteryService.getUUID(), HeaterServices.deviceFirmwareUpdateService.getUUID()]
        currentPeripheral?.discoverServices(serviceUUIDs)
    }
}

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
                break
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case HeaterServicesCharacteristics.systemStats.getUUID():
            let temperature = systemStats(from: characteristic)
            delegate?.getSystemStats?(temperature)
        case HeaterServicesCharacteristics.initialOnTime.getUUID():
            let initOnTime = getUInt16Characteristic(from: characteristic)
            delegate?.getInitialOnTime?(initOnTime)
        case HeaterServicesCharacteristics.waveOnTime.getUUID():
            let waveOn = getUInt16Characteristic(from: characteristic)
            delegate?.getWaveOnTime?(waveOn)
        case HeaterServicesCharacteristics.waveOffTime.getUUID():
            let waveOff = getUInt16Characteristic(from: characteristic)
            delegate?.getWaveOffTime?(waveOff)
        case HeaterServicesCharacteristics.waveTimeLimit.getUUID():
            let waveLimit = getUInt16Characteristic(from: characteristic)
            delegate?.getWaveTimeLimit?(waveLimit)
        case HeaterServicesCharacteristics.tempUpperLimit.getUUID():
            let tempUpper = getUInt8Characteristic(from: characteristic)
            delegate?.getTempUpperLimit?(tempUpper)
        case HeaterServicesCharacteristics.controlStatus.getUUID():
            let status = getUInt8Characteristic(from: characteristic)
            delegate?.getControlStatus?(status)
        case HeaterServicesCharacteristics.batteryLevel.getUUID():
            let level = batteryLevel(from: characteristic)
            delegate?.getBatteryLevel?(level)
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("error occured : \(error.localizedDescription)")
        } else {
            print("Value successfully written")
            readValue(for: characteristic)
        }
    }
}

extension BLEManager {
    func systemStats(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return 0 }
        let currentTemperature = CharacteristicReader.readIntValue(data: characteristicData)
        return currentTemperature
    }
    
    func getUInt8Characteristic(from characteristic: CBCharacteristic) -> UInt8 {
        guard let characteristicData = characteristic.value else { return 0 }
        let currentInitialOnTime = CharacteristicReader.readUInt8Value(data: characteristicData)
        return currentInitialOnTime
    }
    
    func getUInt16Characteristic(from characteristic: CBCharacteristic) -> UInt16 {
        guard let characteristicData = characteristic.value else { return 0 }
        let currentInitialOnTime = CharacteristicReader.readUInt16Value(data: characteristicData)
        return currentInitialOnTime
    }
    
    func batteryLevel(from characteristic: CBCharacteristic) -> String {
        guard let characteristicData = characteristic.value else { return  "Error" }
        let currentBatteryLevel = CharacteristicReader.readUInt8Value(data: characteristicData)
        return "\(Int(currentBatteryLevel))"
    }
}
