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
        NotificationCenter.default.addObserver(self, selector: #selector(updateSettings), name: .updateSettings, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showWalls), name: .showWalls, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showProgramMode), name: .showProgramMode, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showCurrentProgram), name: .showCurrentProgram, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateOpacity), name: .updateOpacity, object: nil)
    }

    @objc func updateSettings(notification: Notification) {
        if let newSettings = notification.object as! Settings? {
            self.settings = newSettings
            //applySettings();
        }
    }
    
    func applySettings() {
        crossHair.isHidden = true
        shooterProgramButton.isHidden = true
        undoProgramButton.isHidden = true
        
        if settings.programingMode {
            crossHair.isHidden = false
            shooterProgramButton.isHidden = false
            showGraphs()
        } else {
            for node in programProgrammingMode.reversed() {
                node.removeFromParentNode()
                programPoints.append(programProgrammingMode.removeLast())
            }
        }
        
        if settings.visualizeProgram {
            for node in programPoints {
                sceneView.scene.rootNode.addChildNode(node)
                
            }
        } else {
            for node in programPoints {
                node.removeFromParentNode()
            }
        }
        
        guard (nodeHolder != nil) else {return}
        
        for node in sceneWalls {
            node.removeFromParentNode()
        }
        
        if settings.robotWalls {
            let scene = SCNScene(named: "art.scnassets/walls.scn")!
            for nodeInScene in scene.rootNode.childNodes as [SCNNode] {
                nodeInScene.opacity = CGFloat(settings.robotWallsOpacity)
                nodeHolder.addChildNode(nodeInScene)
                sceneWalls.append(nodeInScene)
            }
        }
    }
    
    @objc func showWalls(notification: Notification) {
        if let newSettings = notification.object as! Settings? {
            self.settings = newSettings
            
            if settings.robotWalls {
                let scene = SCNScene(named: "art.scnassets/walls.scn")!
                for nodeInScene in scene.rootNode.childNodes as [SCNNode] {
                    nodeInScene.opacity = CGFloat(settings.robotWallsOpacity)
                    nodeHolder.addChildNode(nodeInScene)
                    sceneWalls.append(nodeInScene)
                }
            } else {
                for node in sceneWalls {
                    node.removeFromParentNode()
                }
            }
        }
    }
    
    @objc func showProgramMode(notification: Notification) {
        if let newSettings = notification.object as! Settings? {
            self.settings = newSettings
            if settings.programingMode {
                crossHair.isHidden = false
                shooterProgramButton.isHidden = false
                undoProgramButton.isHidden = false
                showGraphs()
            } else {
                crossHair.isHidden = true
                shooterProgramButton.isHidden = true
                undoProgramButton.isHidden = true
                for node in programProgrammingMode.reversed() {
                    node.removeFromParentNode()
                    programPoints.append(programProgrammingMode.removeLast())
                }
            }
        }
    }
    
    @objc func showCurrentProgram(notification: Notification) {
        if let newSettings = notification.object as! Settings? {
            self.settings = newSettings
            if settings.visualizeProgram {
                for node in programPoints {
                    sceneView.scene.rootNode.addChildNode(node)
                    
                }
            } else {
                for node in programPoints {
                    node.removeFromParentNode()
                }
            }
            
        }
    }
    
    @objc func updateOpacity(notification: Notification) {
        if let newSettings = notification.object as! Settings? {
            self.settings = newSettings
            for nodeC in nodeHolder.childNodes {
                if let string = nodeC.name, string.contains("Wall") {
                    nodeC.opacity = CGFloat(settings.robotWallsOpacity)
                    print("Changing something: \(string)")
                }
                
            }
        }
    }

}

extension Notification.Name {
    static let updateSettings = Notification.Name("updateSettings")
    static let showWalls = Notification.Name("showWalls")
    static let showProgramMode = Notification.Name("showProgramMode")
    static let showCurrentProgram = Notification.Name("showCurrentProgram")
    static let updateOpacity = Notification.Name("updateOpacity")
}