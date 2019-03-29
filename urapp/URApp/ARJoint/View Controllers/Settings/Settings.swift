//
//  Settings.swift
//  URApp
//
//  Created by XavierRoma on 17/03/2019.
//  Copyright © 2019 x.roma_gabriel.cammany. All rights reserved.
//

import Foundation

struct Settings {
    
    var robotSpeed = 90.0
    var robotIP = "192.168.1.40"
    var robotPort = 30100
    var webAddress = "urportal.sytes.net"
    var syncQrCode = 10
    var programingMode = false
    var robotWalls = false
    var robotWallsOpacity = 50.0
    var virtualControls = true
    var visualizeProgram = false
    var editModeWalls = true
    
}

struct Operations {
    
    // State booleans for the render function
    var isMonitoring = false
    var isWallChanging = false
    var isSettingPosition = true
    var isShowingCurrentProgram = false
    var isInProgramMode = false
    var isUpdatingOpacity = false
    var isAddingProgramPoint = false
    
}
