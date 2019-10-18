//
//  DetailViewController.swift
//  BluetoothTest
//
//  Created by Mahnoor Khan on 17/10/2019.
//  Copyright © 2019 Mahnoor Khan. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var waveOnTime           : UILabel!
    @IBOutlet weak var waveOffTime          : UILabel!
    @IBOutlet weak var temperature          : UILabel!
    @IBOutlet weak var initialOnTime        : UILabel!
    @IBOutlet weak var waveTimeLimit        : UILabel!
    @IBOutlet weak var controlStatus        : UILabel!
    @IBOutlet weak var tempUpperLimit       : UILabel!
    @IBOutlet weak var connectionStatus     : UILabel!
    @IBOutlet weak var batteryPercentage    : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initManager()
    }
}

extension DetailViewController {
    func setConnectionStatus(_ status: String) {
        connectionStatus.text = status
    }
    
    func initManager() {
        BLEManager.shared.delegate = self

        BLEManager.shared.getConnectionStatus = { [weak self] status in
            self?.connectionStatus.text = "Connected to \(status)."
        }
    }
    
    @IBAction func writeWaveOnTime(_ sender: UIButton) {
        let val = UInt16(2600)
        writeWaveOnTime(val)
    }
}

extension DetailViewController: BLEDelegate {
    func getSystemStats(_ currentTemperature: Int) {
        temperature.text = "Temperature: \(currentTemperature)"
    }
    
    func getInitialOnTime(_ currentOnTime: UInt16) {
        initialOnTime.text = "Initial On Time: \(currentOnTime)"
    }
    
    func getWaveOnTime(_ currentWaveOnTime: UInt16) {
        waveOnTime.text = "Wave On Time: \(currentWaveOnTime)"
    }
    
    func getWaveOffTime(_ currentWaveOffTime: UInt16) {
        waveOffTime.text = "Wave Off Time: \(currentWaveOffTime)"
    }
    
    func getWaveTimeLimit(_ currentWaveTimeLimit: UInt16) {
        waveTimeLimit.text = "Wave Time Limit: \(currentWaveTimeLimit)"
    }
    
    func getTempUpperLimit(_ currentTempUpperLimit: UInt8) {
        tempUpperLimit.text = "Temp Upper Limit: \(currentTempUpperLimit)"
    }
    
    func getControlStatus(_ currentControlStatus: UInt8) {
        controlStatus.text = "Control Status: \(currentControlStatus)"
    }
    
    func getBatteryLevel(_ batteryLevel: String) {
        batteryPercentage.text = "Battery Level: \(batteryLevel)"
    }
}
