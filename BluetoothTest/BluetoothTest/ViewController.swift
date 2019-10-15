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

    @IBOutlet weak var lbl      : UILabel!
    @IBOutlet weak var lbl2      : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let manager = BLEManager.shared
        manager.setDeviceName(deviceName: "Brilliantly Warm")
        manager.setConnectionStatus = { connectionStatus in
            self.lbl.text = connectionStatus
        }
        manager.setBatteryLevel = { batteryLevel in
            self.lbl2.text = batteryLevel
        }
    }
}
