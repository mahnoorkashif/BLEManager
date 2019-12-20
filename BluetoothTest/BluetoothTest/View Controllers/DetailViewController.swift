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
    
    var status                              : UInt8?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerDataManagerClosures()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BLEManager.shared.disconnectCurrentPeripheral()
        DataManager.shared.resetListners()
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
        let value = Int.random(in: 1...65000)
        CharacteristicHandler.writeCharacteristic(.initialOnTime, value)
        BLEManager.shared.readValue(for: .initialOnTime)
    }
    
    @IBAction func changeWaveOnTime(_ sender: UIButton) {
        let value = Int.random(in: 1...65000)
        CharacteristicHandler.writeCharacteristic(.waveOnTime, value)
        BLEManager.shared.readValue(for: .waveOnTime)
    }
    
    @IBAction func changeWaveOffTime(_ sender: UIButton) {
        let value = Int.random(in: 1...65000)
        CharacteristicHandler.writeCharacteristic(.waveOffTime, value)
        BLEManager.shared.readValue(for: .waveOffTime)
    }
    
    @IBAction func changeWaveTimeLimit(_ sender: UIButton) {
        let value = Int.random(in: 60...10800)
        CharacteristicHandler.writeCharacteristic(.waveTimeLimit, value)
        BLEManager.shared.readValue(for: .waveTimeLimit)
    }
    
    @IBAction func changeTempUpperLimit(_ sender: UIButton) {
        let value = Int.random(in: 30...43)
        CharacteristicHandler.writeCharacteristic(.tempUpperLimit, value)
        BLEManager.shared.readValue(for: .tempUpperLimit)
    }
    
    @IBAction func changeControlStatus(_ sender: UIButton) {
        switch status {
        case ControlStatusValues.on.rawValue:
            CharacteristicHandler.writeCharacteristic(.controlStatus, 1)
        case ControlStatusValues.off.rawValue:
            CharacteristicHandler.writeCharacteristic(.controlStatus, 2)
        case ControlStatusValues.onh.rawValue:
            CharacteristicHandler.writeCharacteristic(.controlStatus, 1)
        case ControlStatusValues.onn.rawValue:
            CharacteristicHandler.writeCharacteristic(.controlStatus, 1)
        default:
            break
        }
        BLEManager.shared.readValue(for: .controlStatus)
    }
}

extension DetailViewController {
    func registerDataManagerClosures() {
        DataManager.shared.batteryLevelChanged = { [weak self] (level)  in
            guard let self = self else { return }
            self.getBatteryLevel(level)
        }
        
        DataManager.shared.systemStatsChanged = { [weak self] (stats)  in
            guard let self = self else { return }
            self.getSystemStats(stats)
        }
        
        DataManager.shared.initialOnTimeChanged = { [weak self] (time)  in
            guard let self = self else { return }
            self.getInitialOnTime(time)
        }
        
        DataManager.shared.waveOnTimeChanged = { [weak self] (time)  in
            guard let self = self else { return }
            self.getWaveOnTime(time)
        }
        
        DataManager.shared.waveOffTimeChanged = { [weak self] (time)  in
            guard let self = self else { return }
            self.getWaveOffTime(time)
        }
        
        DataManager.shared.waveTimeChanged = { [weak self] (time)  in
            guard let self = self else { return }
            self.getWaveTimeLimit(time)
        }
        
        DataManager.shared.tempUpperLimitChanged = { [weak self] (limit)  in
            guard let self = self else { return }
            self.getTempUpperLimit(limit)
        }
        
        DataManager.shared.controlStatusChanged = { [weak self] (status)  in
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
