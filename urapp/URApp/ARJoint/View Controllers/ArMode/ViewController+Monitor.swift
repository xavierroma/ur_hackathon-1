//
//  File.swift
//  URApp
//
//  Created by XavierRoma on 29/03/2019.
//  Copyright © 2019 x.roma_gabriel.cammany. All rights reserved.
//

import Foundation
import ARKit

extension ViewController {
    
    func stopAllJointMonitor () {
        
        for joint in jointsBalls {
            joint.removeFromParentNode()
        }
        
    }
    
    func startAllJointMonitor () {
        
        for i in 0...(self.data.MAX_JOINTS - 1) {
            let node = SCNNode(geometry: SCNSphere(radius: 0.05))
            node.opacity = 0.1
            node.name = "Joint-\(i)"
            jointsBalls.append(node)
            self.nodeHolder.addChildNode(node)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            while (self.operations.isMonitoring) {
               
                let out =  self.robotSockets[RobotSockets.joints_pos.rawValue].read(information.get_all_joint_positions_json)
                do {
                    let json = try JSONSerialization.jsonObject(with: out as Data) as? [[Any]]
                    for i in 1...(self.data.MAX_JOINTS) {
                        var j = 0
                        for pos in json?[i - 1] as! [NSNumber] {
                            self.data.jointData[i - 1].position[j] = "\(pos)"
                            j += 1
                        }
                    }
                    usleep(10000)
                }
                catch {
                }
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            while (self.operations.isMonitoring) {
                
                let out = self.robotSockets[RobotSockets.current.rawValue]
                    .read(information.actual_current_json)
                do {
                    let json = try JSONSerialization.jsonObject(with: out as Data) as? [Any]
                    for i in 1...(self.data.MAX_JOINTS) {
                        let str = "\(json?[i - 1] ?? self.data.jointData[i - 1].jointCurrent)"
                        guard str.count >= 5 else {continue}
                        self.data.jointData[i - 1].jointCurrent = String(str[str.startIndex ..< (str.index(str.startIndex, offsetBy: 5))])
                    }
                    usleep(1000000)
                } catch {
                }
            }
        }
        DispatchQueue.global(qos: .background).async {
            while (self.operations.isMonitoring) {
                
                let out = self.robotSockets[RobotSockets.temp.rawValue]
                    .read(information.joint_temperatures_json)
                do {
                    let json = try JSONSerialization.jsonObject(with: out as Data) as? [Any]
                    for i in 1...(self.data.MAX_JOINTS) {
                        let str = "\(json?[i - 1] ?? self.data.jointData[i - 1].jointTemp)"
                        guard str.count >= 4 else {continue}
                        self.data.jointData[i - 1].jointTemp = String(str[str.startIndex ..< (str.index(str.startIndex, offsetBy: 4))])
                    }
                    usleep(1000000)
                }
                catch {
                }
            }
        }
        
    }
    
    func startGeneralMonitor () {
        DispatchQueue.global(qos: .userInitiated).async {
            while (self.operations.isMonitoring) {
                
                let out = self.robotSockets[RobotSockets.info.rawValue]
                    .read(information.get_all_json)
                do {
                    let json = try JSONSerialization.jsonObject(with: out as Data) as? [[Any]]
                    print(json)
                    usleep(1000000)
                }
                catch {
                }
            }
        }
    }
    
    
    func monitorWalls () {
        let client = RobotMonitoring(settings.robotIP, Int32(settings.robotPort))
        client.connect()
        if client.init_succeed {
            do {
                let out = client.read(.get_walls_json) as Data
                print(out)
            let json = try JSONSerialization.jsonObject(with: out) as? Any
                print("Walls: \(json ?? "nothing")")
            } catch {
                print("Walls: nothing")
            }
            client.close()
        }
        
    }
    
}
