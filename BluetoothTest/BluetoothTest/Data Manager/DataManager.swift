//
//  DataManager.swift
//  BluetoothTest
//
//  Created by Mahnoor Khan on 20/12/2019.
//  Copyright © 2019 Mahnoor Khan. All rights reserved.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    var heaterModel   = HeaterModel()
    
    var waveTimeChanged                 : ((UInt16)->())? = nil
    var waveOnTimeChanged               : ((UInt16)->())? = nil
    var waveOffTimeChanged              : ((UInt16)->())? = nil
    var systemStatsChanged              : ((Int)->())?    = nil
    var batteryLevelChanged             : ((String)->())? = nil
    var controlStatusChanged            : ((UInt8)->())?  = nil
    var initialOnTimeChanged            : ((UInt16)->())? = nil
    var tempUpperLimitChanged           : ((UInt8)->())?  = nil
    
    func waveTimeUpdated(waveTime: UInt16) {
        heaterModel.waveTime = "\(waveTime)"
        waveTimeChanged?(waveTime)
    }
    
    func waveOnTimeUpdated(waveOnTime: UInt16) {
        heaterModel.waveOnTime = "\(waveOnTime)"
        waveOnTimeChanged?(waveOnTime)
    }
    
    func waveOffTimeUpdated(waveOffTime: UInt16) {
        heaterModel.waveOffTime = "\(waveOffTime)"
        waveOffTimeChanged?(waveOffTime)
    }
    
    func systemStatsUpdated(systemStats: Int) {
        heaterModel.systemStats = "\(systemStats)"
        systemStatsChanged?(systemStats)
    }
    
    func batteryLevelUpdated(battery: String) {
        heaterModel.battery = "\(battery)"
        batteryLevelChanged?(battery)
    }
    
    func controlStatusUpdated(status: UInt8) {
        heaterModel.controlStatus = "\(status)"
        controlStatusChanged?(status)
    }
    
    func initialOnTimeUpdated(initialOnTime: UInt16) {
        heaterModel.initialOnTime = "\(initialOnTime)"
        initialOnTimeChanged?(initialOnTime)
    }
    
    func tempUpperLimitUpdated(tempUpperLimit: UInt8) {
        heaterModel.tempUpperLimit = "\(tempUpperLimit)"
        tempUpperLimitChanged?(tempUpperLimit)
    }
    
    /// Function to reset Characteristic Listeners.
    func resetListners() {
        waveTimeChanged       = nil
        waveOnTimeChanged     = nil
        waveOffTimeChanged    = nil
        systemStatsChanged    = nil
        batteryLevelChanged   = nil
        controlStatusChanged  = nil
        initialOnTimeChanged  = nil
        tempUpperLimitChanged = nil
    }
}
