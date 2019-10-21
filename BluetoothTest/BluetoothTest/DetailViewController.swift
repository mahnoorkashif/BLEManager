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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerBLEClosures()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BLEManager.shared.disconnectPeripheral()
        BLEManager.shared.resetListners()
    }
}

extension DetailViewController {
    func setConnectionStatus(_ status: String) {
        connectionStatus.text = status
    }
    
    func initManager() {
        BLEManager.shared.getConnectionStatus = { [weak self] status in
            self?.connectionStatus.text = "Connected to \(status)."
        }
    }
}

extension DetailViewController {
    @IBAction func changeInitialOnTime(_ sender: UIButton) {
        let number = Int.random(in: 1...65000)
        if number >= 1 && number <= 65000 {
            let val = UInt16(number)
            BLEManager.shared.writeInitalOnTime(val)
            BLEManager.shared.readInitalOnTime()
        } else { return }
    }
    
    @IBAction func changeWaveOnTime(_ sender: UIButton) {
        let number = Int.random(in: 1...65000)
        if number >= 1 && number <= 65000 {
            let val = UInt16(number)
            BLEManager.shared.writeWaveOnTime(val)
            BLEManager.shared.readWaveOnTime()
        } else { return }
    }
    
    @IBAction func changeWaveOffTime(_ sender: UIButton) {
        let number = Int.random(in: 1...65000)
        if number >= 1 && number <= 65000 {
            let val = UInt16(number)
            BLEManager.shared.writeWaveOffTime(val)
            BLEManager.shared.readWaveOffTime()
        } else { return }
    }
    
    @IBAction func changeWaveTimeLimit(_ sender: UIButton) {
        let number = Int.random(in: 60...10800)
        if number >= 60 && number <= 10800 {
            let val = UInt16(number)
            BLEManager.shared.writeWaveTimeLimit(val)
            BLEManager.shared.readWaveTimeLimit()
        } else { return }
    }
    
    @IBAction func changeTempUpperLimit(_ sender: UIButton) {
        let number = Int.random(in: 30...43)
        if number >= 30 && number <= 43 {
            let val = UInt8(number)
            BLEManager.shared.writeTempUpperLimit(val)
            BLEManager.shared.readTempUpperLimit()
        } else { return }
    }
    
    @IBAction func changeControlStatus(_ sender: UIButton) {
        switch status {
        case ControlStatusValues.on.rawValue:
            BLEManager.shared.writeControlStatus(ControlStatusValues.off.rawValue)
        case ControlStatusValues.off.rawValue:
            BLEManager.shared.writeControlStatus(ControlStatusValues.on.rawValue)
        case ControlStatusValues.onh.rawValue:
            BLEManager.shared.writeControlStatus(ControlStatusValues.off.rawValue)
        case ControlStatusValues.onn.rawValue:
            BLEManager.shared.writeControlStatus(ControlStatusValues.off.rawValue)
        default:
            break
        }
        BLEManager.shared.readControlStatus()
    }
}

extension DetailViewController {
    func registerBLEClosures() {
        BLEManager.shared.batteryLevelChanged = { [weak self] (level)  in
            guard let self = self else { return }
            self.getBatteryLevel(level)
        }
        
        BLEManager.shared.systemStatsChanged = { [weak self] (stats)  in
            guard let self = self else { return }
            self.getSystemStats(stats)
        }
        
        BLEManager.shared.initialOnTimeChanged = { [weak self] (time)  in
            guard let self = self else { return }
            self.getInitialOnTime(time)
        }
        
        BLEManager.shared.waveOnTimeChanged = { [weak self] (time)  in
            guard let self = self else { return }
            self.getWaveOnTime(time)
        }
        
        BLEManager.shared.waveOffTimeChanged = { [weak self] (time)  in
            guard let self = self else { return }
            self.getWaveOffTime(time)
        }
        
        BLEManager.shared.waveTimeChanged = { [weak self] (time)  in
            guard let self = self else { return }
            self.getWaveTimeLimit(time)
        }
        
        BLEManager.shared.tempUpperLimitChanged = { [weak self] (limit)  in
            guard let self = self else { return }
            self.getTempUpperLimit(limit)
        }
        
        BLEManager.shared.controlStatusChanged = { [weak self] (status)  in
            guard let self = self else { return }
            self.getControlStatus(status)
        }
    }
    
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
