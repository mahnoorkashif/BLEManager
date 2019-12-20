//
//  BLEManager.swift
//  BluetoothTest
//
//  Created by Mahnoor Khan on 15/10/2019.
//  Copyright © 2019 Mahnoor Khan. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEManager: NSObject {
    //MARK:- Properties
    private var deviceName              : String?
    static let shared                   = BLEManager()

    internal var currentPeripheral      : CBPeripheral?
    private(set) var centralManager     : CBCentralManager?
    private(set) var allPeripherals     : [CBPeripheral]?
    
    var getConnectionStatus             : ((String)->())?
    var addNewPeripheralToList          : (([CBPeripheral])->())?
    
    internal var characteristicMap       : [(type: HeaterServicesCharacteristics, object: CBCharacteristic?)] = []
    
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
    
    func readValue(for characteristic: HeaterServicesCharacteristics) {
        guard let characteristic = BLEManager.shared.getCharacteristics(with: characteristic.getValue()) else { return }
        if characteristic.service.uuid == HeaterServices.batteryService.getUUID() {
            BatteryServiceHandler.shared.readValue(for: characteristic)
        } else if characteristic.service.uuid == HeaterServices.customService.getUUID() {
            CustomServiceHandler.shared.readValue(for: characteristic)
        }
    }
    
    func connectToPeripheral(at index: Int) {
        guard let newCurrent = BLEManager.shared.allPeripherals?[index] else { return }
        BLEManager.shared.disconnectCurrentPeripheral()
        BLEManager.shared.setCurrentPeripheral(newCurrent)
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
        if service.uuid == HeaterServices.batteryService.getUUID() {
            BatteryServiceHandler.shared.didDiscoverBatteryCharacteristics(peripheral, didDiscoverCharacteristicsFor: service, error: error)
        } else if service.uuid == HeaterServices.customService.getUUID() {
            CustomServiceHandler.shared.didDiscoverBatteryCharacteristics(peripheral, didDiscoverCharacteristicsFor: service, error: error)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.service.uuid == HeaterServices.batteryService.getUUID() {
            BatteryServiceHandler.shared.didUpdateBatteryCharacteristics(peripheral, didUpdateValueFor: characteristic, error: error)
        } else if characteristic.service.uuid == HeaterServices.customService.getUUID() {
            CustomServiceHandler.shared.didUpdateBatteryCharacteristics(peripheral, didUpdateValueFor: characteristic, error: error)
        }
    }
}
