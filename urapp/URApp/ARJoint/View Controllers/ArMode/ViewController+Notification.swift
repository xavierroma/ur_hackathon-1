//
//  ViewController+Notification.swift
//  URApp
//
//  Created by XavierRoma on 27/03/2019.
//  Copyright © 2019 x.roma_gabriel.cammany. All rights reserved.
//

import Foundation
import ARKit


extension ViewController {

    func setUpNotifications () {
        NotificationCenter.default.addObserver(self, selector: #selector(showWalls), name: .showWalls, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showProgramMode), name: .showProgramMode, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showCurrentProgram), name: .showCurrentProgram, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateOpacity), name: .updateOpacity, object: nil)
    }
    
    @objc func showWalls(notification: Notification) {
        if let isOn = notification.object as? Bool {
            settings.robotWalls = isOn
            self.operations.isWallChanging = true
            self.operations.isSettingPosition = false;
        }
    }
    
    
    @objc func showProgramMode(notification: Notification) {
        if let newSettings = notification.object as! Settings? {
            self.settings = newSettings
            self.operations.isInProgramMode = true
        }
    }
    
    @objc func showCurrentProgram(notification: Notification) {
        if let newSettings = notification.object as! Settings? {
            self.settings = newSettings
            self.operations.isShowingCurrentProgram = true
        }
    }
    
    @objc func updateOpacity(notification: Notification) {
        if let newSettings = notification.object as! Settings? {
            self.settings = newSettings
            self.operations.isUpdatingOpacity = true
        }
    }
    
    

}

extension Notification.Name {
    static let showWalls = Notification.Name("showWalls")
    static let showProgramMode = Notification.Name("showProgramMode")
    static let showCurrentProgram = Notification.Name("showCurrentProgram")
    static let updateOpacity = Notification.Name("updateOpacity")
    static let showGraphs = Notification.Name("showGraphs")
    static let setUpARConfirmation = Notification.Name("userConfirmARSetUp")
}

