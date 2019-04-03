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
        NotificationCenter.default.addObserver(self, selector: #selector(showRobotJointInfo), name: .showRobotJointInfo, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showGraphsAction), name: .showGraphs, object: nil)
    }
    
    @objc func showWalls(notification: Notification) {
        if let isOn = notification.object as? Bool {
            settings.robotWalls = isOn
            self.operations.isWallChanging = isOn
        }
    }
    
    @objc func showRobotJointInfo(notification: Notification) {
        if let isOn = notification.object as? Bool {
            settings.robotJoints = isOn
            print("robot joint info is: \(isOn)")
            self.operations.isMonitoring = isOn
            self.operations.startJointsMonitor = isOn
            self.operations.stopJointsMonitor = !isOn
            
        }
    }
    
    
    @objc func showProgramMode(notification: Notification) {
        if let isOn = notification.object as? Bool {
            self.settings.programingMode = isOn
            self.operations.isInProgramMode = isOn
            undoProgramButton.isHidden = !isOn
            crossHair.isHidden = !isOn
            shooterProgramButton.isHidden = !isOn
            zSlider.isHidden = !isOn
            endefectorButton.isHidden = !isOn
            saveButton.isHidden = !isOn
            sliderProgramView.isHidden = !isOn
            confirmPointButton.isHidden = !isOn
            
        }
    }
    
    @objc func showCurrentProgram(notification: Notification) {
         if let isOn = notification.object as? Bool {
            self.settings.visualizeProgram = isOn
            self.operations.isShowingCurrentProgram = isOn
            
        }
    }
    
    @objc func updateOpacity(notification: Notification) {
         if let opacity = notification.object as? Double {
            self.settings.robotWallsOpacity = opacity
            self.operations.isUpdatingOpacity = true
        }
    }
    
    @objc func showGraphsAction(notification: Notification) {
         if let isOn = notification.object as? Bool {
            if (isOn) {
                showGraphs()
            } else {
                if (chartNode != nil ) {
                    chartNode.removeFromParentNode()
                }
            }
            
        }
    }
    
    
    
    

}

extension Notification.Name {
    static let showWalls = Notification.Name("showWalls")
    static let showProgramMode = Notification.Name("showProgramMode")
    static let showCurrentProgram = Notification.Name("showCurrentProgram")
    static let updateOpacity = Notification.Name("updateOpacity")
    static let showRobotJointInfo = Notification.Name("showRobotJointInfo")
    static let showGraphs = Notification.Name("showGraphs")
}

