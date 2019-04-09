//
//  ViewController.swift
//  test
//
//  Created by XavierRoma on 08/03/2019.
//  Copyright © 2019 Salle URL. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import WebKit

extension ViewController: ARSCNViewDelegate{
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        DispatchQueue.main.async {
            self.updateFocusSquare(isObjectVisible: false)
        }
        
        if self.operations.startJointsMonitor {
            jointBallsNodesInit()
            self.operations.startJointsMonitor = false
        
        } else if self.operations.stopJointsMonitor {
            jointBallsNodesDestroy()
            self.operations.stopJointsMonitor = false
        }
        
        if self.operations.callibrationEnded {
            self.operations.callibrationEnded = false
            let aux = SCNNode()
            
            for node in nodeHolder.childNodes {
                aux.addChildNode(node)
            }
            let anchor = ARAnchor(transform: nodeHolder.simdTransform)
            sceneView.session.add(anchor: anchor)
            
            nodeHolder.removeFromParentNode()
            aux.transform = nodeHolder.transform
            nodeHolder = nil
            aux.transform.m21 = 0.0
            aux.transform.m22 = 1.0
            aux.transform.m23 = 0.0
            
            
            nodeHolder = aux
            sceneView.scene.rootNode.addChildNode(nodeHolder)
            /*let ball = SCNSphere(radius: 0.01)
            let newBall = SCNNode(geometry: ball)
            newBall.position = Utilities.ARToRobotCoord(ar_position:  SCNVector3(0,0,0))
            nodeHolder.addChildNode(newBall)*/
        }
        
        if (self.operations.isJointMonitoring) {
                
                DispatchQueue.main.async {
                    for i in 0...(self.data.MAX_JOINTS - 1) {

                        guard let x = Float(self.data.jointData[i].position[0]),
                            let y = Float(self.data.jointData[i].position[2]),
                            let z = Float(self.data.jointData[i].position[1])  else {continue}

                        self.jointsBalls[i].transform.m41 = x * -1 - 0.65
                        self.jointsBalls[i].transform.m42 = y + 0.152
                        self.jointsBalls[i].transform.m43 = z - 0.275
                        self.jointsBalls[i].geometry?.firstMaterial?.diffuse.contents = self.data.jointData[i].jointColor
                        if (self.joinSelected == i) {
                            self.joint.transform = self.jointsBalls[self.joinSelected].transform
                            self.joint.updateValues(temp: "\(self.data.jointData[self.joinSelected].jointTemp) ºC",
                                current: "\(self.data.jointData[self.joinSelected].jointCurrent) A",
                                voltage: "\(self.data.jointData[self.joinSelected].jointVolatge) V",
                                speed: "\(self.data.jointData[self.joinSelected].jointSpeed) rad/s")
                            self.joint.constraints = [SCNBillboardConstraint()]
                        }
                        
                    }
                }
        }
       
        if (self.operations.placeJointInfo) {
            self.joint.removeFromParentNode()
            self.joint.transform = self.jointsBalls[self.joinSelected].transform
            self.nodeHolder.addChildNode(self.joint)
            self.operations.placeJointInfo = false
        }
        
        if (self.operations.isWallChanging) {
            self.updateWalls()
            
            self.operations.isWallChanging = false
        }
        
        if self.operations.isShowingCurrentProgram {
            self.updateShowCurrentProgram()
            self.operations.isShowingCurrentProgram = false
        }
        
        if self.operations.isInProgramMode {
            DispatchQueue.main.async {
                
                for operation in self.programOperationsQueue {
                    switch operation {
                    case .create:
                        
                        if self.lastARLine != nil {
                            self.programProgrammingMode.append(self.lastARLine)
                            self.lastARLine = nil
                        }
                        
                        if self.lastARPPoint != nil {
                            if self.lastPPoint != nil {
                                self.programPointsRobotData.append(self.lastPPoint)
                                self.lastPPoint = nil
                            }
                            self.programProgrammingMode.append(self.lastARPPoint)
                            self.lastARPPoint = nil
                        }
                        
                        self.addProgramPoint()
                        
                        break
                        
                    case .update:
                       
                        if self.lastARPPoint != nil && self.programProgrammingMode.last != nil {
                            
                            var pos = self.lastARPPoint.position
                            pos.y = self.nodeHolder.position.y + self.zSlider.value - 0.152
                            
                            self.updateLine(
                                fromPos: self.programProgrammingMode.last!.position,
                                pos: pos)
                        }
                        break
                        
                    case .remove:
                        
                        if self.lastARPPoint != nil {
                            self.lastARPPoint.removeFromParentNode()
                            self.lastARPPoint = self.programProgrammingMode.popLast()
                        }
                        
                        if self.lastARLine != nil {
                            self.lastARLine.removeFromParentNode()
                            self.lastARLine = self.programProgrammingMode.popLast()
                        }
                        
                        break
                        
                    case .confirm:
                        
                        if self.lastARLine != nil {
                            self.programProgrammingMode.append(self.lastARLine)
                            self.lastARLine = nil
                        }
                        
                        if self.lastARPPoint != nil {
                            self.programProgrammingMode.append(self.lastARPPoint)
                            var pos = self.lastARPPoint.position
                            pos.y = self.nodeHolder.position.y + self.zSlider.value - 0.152
                            self.lastARPPoint = nil
                            self.createPoint(atPos: pos)
                        }
                        break
                    }
                }
                
                self.programOperationsQueue.removeAll()
                
            }
        }
        
        if (self.operations.isUpdatingOpacity) {
            self.updateRenderOpacity()
            self.operations.isUpdatingOpacity = false
        }
        
        
        
        
        
        
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard operations.isSettingPosition, let imageAnchor = anchor as? ARImageAnchor
            else { return }
        
        switch imageAnchor.name {
        case "1":
            statusViewController.showMessage("Posición de inicio encontrada!", autoHide: true)
            
            if nodeHolder != nil, nodeHolder.parent != nil {
                nodeHolder.removeFromParentNode()
            }
            
            nodeHolder = SCNNode()
            nodeHolder = node
            nodeHolder.transform.m21 = 0.0
            nodeHolder.transform.m22 = 1.0
            nodeHolder.transform.m23 = 0.0
            
            //nodeHolder.transform.m42 = result.worldTransform.columns.3.y
            let scene = SCNScene(named: "art.scnassets/ship.scn")!
            
            for nodeInScene in scene.rootNode.childNodes as [SCNNode] {
                nodeHolder.addChildNode(nodeInScene)
            }
            
            sceneView.scene.rootNode.addChildNode(nodeHolder)
            break
        default:
            break
        }
    }
    func updateWalls() {
        if settings.robotWalls {
 
            for node in sceneWalls {
                node.opacity = CGFloat(settings.robotWallsOpacity)
                nodeHolder.addChildNode(node)
            }
            
        } else {
            for node in sceneWalls {
                node.removeFromParentNode()
            }
        }
    }
    
    func updateRenderOpacity() {
        for nodeC in nodeHolder.childNodes {
            if let string = nodeC.name, string.contains("Wall") {
                nodeC.opacity = CGFloat(settings.robotWallsOpacity)
            }
        }
    }
    
    
    func addProgramPoint() {
        
        guard let result = sceneView.hitTest(CGPoint(x: screenCenter.x, y: screenCenter.y), types: [.existingPlaneUsingExtent, .featurePoint]).first else { return }
        
        let pos =  SCNVector3(x: result.worldTransform.columns.3.x, y: nodeHolder.position.y + self.zSlider.value - 0.152, z: result.worldTransform.columns.3.z)
        
        createPoint(atPos: pos)
        
    }
    
    func createPoint (atPos: SCNVector3) {
        
        let sphere = SCNSphere(radius: 0.005)
        
        lastARPPoint = SCNNode(geometry: sphere)
        
        lastARPPoint.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        
        lastARPPoint.position = atPos
        
        let robot_pos = Utilities.ARToRobotCoord(ar_position: sceneView.scene.rootNode.convertPosition(atPos, to: nodeHolder))
        
        lastPPoint = RobotPos(x: String(robot_pos.x), y: String(robot_pos.y), z: String(zSlider.value))
        
        lastPPoint.reproducePosition(com: robotSockets[RobotSockets.comunication.rawValue])
        
        
        if programProgrammingMode.count >= 1 {
            
            let line = lineFrom(vector: (programProgrammingMode.last?.position)!, toVector: lastARPPoint.position)
            lastARLine = SCNNode(geometry: line)
            lastARLine.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
            
            sceneView.scene.rootNode.addChildNode(lastARLine)
            
        }
        //It is important to do this append AFTER the line node is appended
        sceneView.scene.rootNode.addChildNode(lastARPPoint)
        
    }
    
    func updateLine(fromPos: SCNVector3, pos: SCNVector3) {
        if programProgrammingMode.count >= 1 {
            
            if (lastARLine != nil) {
                lastARLine.removeFromParentNode()
            }
            let line = lineFrom(vector: fromPos, toVector: pos)
            lastARLine = SCNNode(geometry: line)
            lastARLine.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
            lastARPPoint.position = pos
            sceneView.scene.rootNode.addChildNode(lastARLine)
            
        }
    }
    
    func updateShowCurrentProgram() {
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
