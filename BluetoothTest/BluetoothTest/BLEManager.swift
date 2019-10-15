//
//  BLEManager.swift
//  BluetoothTest
//
//  Created by Mahnoor Khan on 15/10/2019.
//  Copyright © 2019 Mahnoor Khan. All rights reserved.
//

import Foundation
import CoreBluetooth

let batteryServiceCBUUID = CBUUID(string: "0x180F")
let batteryLevelCharacteristicCBUUID = CBUUID(string: "0x2A19")

class BLEManager: NSObject {
    static let shared                   = BLEManager()
    private var deviceName              : String?
    private var bluetoothPeripheral     : CBPeripheral!
    private var centralManager          : CBCentralManager!
    
    var setConnectionStatus             : ((String)->())?
    var setBatteryLevel                 : ((String)->())?
    
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension BLEManager {
    func setDeviceName(deviceName: String) {
        self.deviceName = deviceName
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
            centralManager.scanForPeripherals(withServices: nil)
        @unknown default:
            print("central.state is .default")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == deviceName {
            bluetoothPeripheral = peripheral
            bluetoothPeripheral.delegate = self
            print(bluetoothPeripheral.name ?? "")
            centralManager.stopScan()
            centralManager.connect(bluetoothPeripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        setConnectionStatus?("Connected to \(peripheral.name ?? "no deivce").")
        peripheral.discoverServices([batteryServiceCBUUID])
    }
}

extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print(service)
            peripheral.discoverCharacteristics([batteryLevelCharacteristicCBUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            print(characteristic)
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case batteryLevelCharacteristicCBUUID:
            print(characteristic.value ?? "no value")
            let level = batteryLevel(from: characteristic)
            setBatteryLevel?(level)
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
    private func batteryLevel(from characteristic: CBCharacteristic) -> String {
        guard let characteristicData = characteristic.value else { return  "Error" }
        let batteryLevel = CharacteristicReader.readUInt8Value(data: characteristicData)
        print(Int(batteryLevel))
        return "Battery Percentage: \(Int(batteryLevel))"
    }
}
