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
        if let isOn = notification.object as? Bool {
            
            settings.robotWalls = isOn
            if isOn {
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
                //showGraphs()
                /*DispatchQueue.global(qos: .background).async {
                    let node = SCNNode(geometry: SCNSphere(radius: 0.01))
                    var pos = self.cleanString(string: self.robotMonitor.read(information.actual_q))
                    if pos.count != 0 {
                        
                        node.position = SCNVector3(Double(pos[0])! - 0.085, Double(pos[2])!, Double(pos[1])! * -1 - 0.325)
                        self.nodeHolder.addChildNode(node)
                    }
                    
                    
                    for _ in 0...1000000 {
                        pos = self.cleanString(string: self.robotMonitor.read(information.actual_q))
                        if pos.count != 0 {
                            
                            node.position = SCNVector3(Double(pos[0])! - 0.085, Double(pos[2])!, Double(pos[1])! * -1 - 0.325)
                            self.nodeHolder.addChildNode(node)
                        }
                    }
                    
                }*/
                DispatchQueue.global(qos: .background).async {
                    var node = [SCNNode()]
                    node.append( SCNNode(geometry: SCNSphere(radius: 0.01)))
                    node.append( SCNNode(geometry: SCNSphere(radius: 0.01)))
                    node.append( SCNNode(geometry: SCNSphere(radius: 0.01)))
                    node.append( SCNNode(geometry: SCNSphere(radius: 0.01)))
                    node.append( SCNNode(geometry: SCNSphere(radius: 0.01)))
                    node.append( SCNNode(geometry: SCNSphere(radius: 0.01)))
                    node.append( SCNNode(geometry: SCNSphere(radius: 0.01)))
                    node.append( SCNNode(geometry: SCNSphere(radius: 0.01)))
                    node.append( SCNNode(geometry: SCNSphere(radius: 0.01)))
                    var i = 1
                    while (true) {
                        
                        let joints = self.cleanString(str: self.robotMonitor.read(information.get_all_joint_positions))
                        if i != 1 {
                            for n in node {
                                n.removeFromParentNode()
                            }
                        }
                        i = 0
                        for pos in joints {
                            node[i].position = SCNVector3(Double(pos[0])! - 0.085, Double(pos[2])! + 0.18, Double(pos[1])! * -1 - 0.325)
                            self.nodeHolder.addChildNode(node[i])
                            i+=1
                        }
                        usleep(100000)
                    }
                }

                
                
                
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
    
    @objc func showGraphs(notification: Notification) {
        showGraphs()
    }
    
    @objc func showJointInfo(notification: Notification) {
        
    }
    
    func cleanString(str: String) -> [[String]] {
        if str.count == 0 {
            return []
        }
        print(str)
        var scope = 0
        var numbers = [[String]]()
        var aux = String()
        var flag = false
        var opened = 0
        for c in str {
            if c == "[" {
                opened += 1
                if ( opened == 2) {
                    numbers.append([String]())
                }
            } else if c == "]" {
                opened -= 1
                if (opened == 1) {
                    numbers[scope].append(aux)
                    flag = true
                    scope += 1
                    aux = ""
                }
                
            } else if c == "," {
                if !flag {
                    numbers[scope].append(aux)
                } else {
                    flag = false
                }
                aux = ""
            } else if c != " " {
                aux.append(c)
            }
            
        }
        print(numbers)
        return numbers
    }

}

extension Notification.Name {
    static let updateSettings = Notification.Name("updateSettings")
    static let showWalls = Notification.Name("showWalls")
    static let showProgramMode = Notification.Name("showProgramMode")
    static let showCurrentProgram = Notification.Name("showCurrentProgram")
    static let updateOpacity = Notification.Name("updateOpacity")
    static let showGraphs = Notification.Name("showGraphs")
}

