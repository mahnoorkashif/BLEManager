//
//  ViewController.swift
//  BluetoothTest
//
//  Created by Mahnoor Khan on 14/10/2019.
//  Copyright © 2019 Mahnoor Khan. All rights reserved.
//

import UIKit
import CoreBluetooth



class ViewController: UIViewController {

    @IBOutlet weak var lbl                  : UILabel!
    @IBOutlet weak var lbl2                 : UILabel!
    @IBOutlet weak var peripheralsTableView : UITableView!
    
    var peripheralDevices                   : [CBPeripheral]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initManager()
        peripheralsTableView.delegate = self
        peripheralsTableView.dataSource = self
    }
}

extension ViewController {
    func initManager() {
        BLEManager.shared.delegate = self
        BLEManager.shared.setDeviceName(deviceName: "Brilliantly Warm")
        
        BLEManager.shared.getConnectionStatus = { connectionStatus in
            self.lbl.text = connectionStatus
        }
        
        BLEManager.shared.reloadTableView = { [weak self] allDevices in
            self?.peripheralDevices = allDevices
            self?.peripheralsTableView.reloadData()
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheralDevices?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = peripheralDevices?[indexPath.row].name ?? "No name"
        return cell
    }
}

extension ViewController: BLEDelegate {
    func getInitialSystemStats(_ currentTemperature: Int) {
        print("Initial Temperature: \(currentTemperature)")
    }
    
    func getInitialOnTime(_ currentOnTime: UInt16) {
        print("Initial On Time: \(currentOnTime)")
    }
    
    func getWaveOnTime(_ currentWaveOnTime: UInt16) {
        print("Initial Wave On Time: \(currentWaveOnTime)")
    }
    
    func getWaveOffTime(_ currentWaveOffTime: UInt16) {
        print("Initial Wave Off Time: \(currentWaveOffTime)")
    }
    
    func getWaveTimeLimit(_ currentWaveTimeLimit: UInt16) {
        print("Initial Wave Time Limit: \(currentWaveTimeLimit)")
    }
    
    func getTempUpperLimit(_ currentTempUpperLimit: UInt8) {
        print("Initial Temp Upper Limit: \(currentTempUpperLimit)")
    }
    
    func getControlStatus(_ currentControlStatus: UInt8) {
        print("Initial Control Status: \(currentControlStatus)")
    }
    
    func getInitialBatteryLevel(_ batteryLevel: String) {
        print("Initial Battery Level: \(batteryLevel)")
    }
}
