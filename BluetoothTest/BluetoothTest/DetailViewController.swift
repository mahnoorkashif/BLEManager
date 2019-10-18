//
//  DetailViewController.swift
//  BluetoothTest
//
//  Created by Mahnoor Khan on 17/10/2019.
//  Copyright © 2019 Mahnoor Khan. All rights reserved.
//

import UIKit

enum ControlStatusValues: UInt8 {
    case on     = 0x02
    case off    = 0x01
    case onh    = 0x03
    case onn    = 0x04
}


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
    
    var status                              : UInt8?
    
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
}

extension DetailViewController {
    @IBAction func changeInitialOnTime(_ sender: UIButton) {
        let number = 10000
        if number >= 1 && number <= 65000 {
            let val = UInt16(number)
            writeInitalOnTime(val)
            readInitalOnTime()
        } else { return }
    }
    
    @IBAction func changeWaveOnTime(_ sender: UIButton) {
        let number = 20000
        if number >= 1 && number <= 65000 {
            let val = UInt16(number)
            writeWaveOnTime(val)
            readWaveOnTime()
        } else { return }
    }
    
    @IBAction func changeWaveOffTime(_ sender: UIButton) {
        let number = 5000
        if number >= 1 && number <= 65000 {
            let val = UInt16(number)
            writeWaveOffTime(val)
            readWaveOffTime()
        } else { return }
    }
    
    @IBAction func changeWaveTimeLimit(_ sender: UIButton) {
        let number = 6000
        if number >= 60 && number <= 10800 {
            let val = UInt16(number)
            writeWaveTimeLimit(val)
            readWaveTimeLimit()
        } else { return }
    }
    
    @IBAction func changeTempUpperLimit(_ sender: UIButton) {
        let number = 38
        if number >= 30 && number <= 43 {
            let val = UInt8(number)
            writeTempUpperLimit(val)
            readTempUpperLimit()
        } else { return }
    }
    
    @IBAction func changeControlStatus(_ sender: UIButton) {
        switch status {
        case ControlStatusValues.on.rawValue:
            writeControlStatus(ControlStatusValues.off.rawValue)
        case ControlStatusValues.off.rawValue:
            writeControlStatus(ControlStatusValues.on.rawValue)
        case ControlStatusValues.onh.rawValue:
            writeControlStatus(ControlStatusValues.off.rawValue)
        case ControlStatusValues.onn.rawValue:
            writeControlStatus(ControlStatusValues.off.rawValue)
        default:
            break
        }
        readControlStatus()
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
        status = currentControlStatus
        switch currentControlStatus {
        case ControlStatusValues.on.rawValue:
            controlStatus.text = "Control Status: On"
        case ControlStatusValues.off.rawValue:
            controlStatus.text = "Control Status: Off"
        case ControlStatusValues.onh.rawValue:
            controlStatus.text = "Control Status: On + Heating"
        case ControlStatusValues.onn.rawValue:
            controlStatus.text = "Control Status: On + Not Heating"
        default:
            break
        }
    }
    
    func getBatteryLevel(_ batteryLevel: String) {
        batteryPercentage.text = "Battery Level: \(batteryLevel)"
    }
}
