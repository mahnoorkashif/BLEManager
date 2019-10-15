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
        BLEManager.shared.setDeviceName(deviceName: "Brilliantly Warm")
        BLEManager.shared.getConnectionStatus = { connectionStatus in
            self.lbl.text = connectionStatus
        }
        BLEManager.shared.getBatteryLevel = { batteryLevel in
//            self.lbl2.text = batteryLevel
            print("hello")
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
