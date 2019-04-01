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
    
    func startAllJointMonitor () {
        
        for i in 0...3 {
            let node = SCNNode(geometry: SCNSphere(radius: 0.05))
            node.opacity = 0.1
            node.name = "Joint-\(i)"
            jointsBalls.append(node)
            self.nodeHolder.addChildNode(node)
        }
        
        operations.isMonitoring = true
        
        DispatchQueue.global(qos: .background).async {
            while (self.operations.isMonitoring) {
                
                let out = self.robotMonitor[0].read(information.actual_current_json)
                do {
                    let json = try JSONSerialization.jsonObject(with: out as Data) as? [Any]
                    for i in 1...4 {
                        let str = "\(json?[i] ?? self.data.jointData[i - 1].jointCurrent)"
                        guard str.count >= 5 else {continue}
                        self.data.jointData[i - 1].jointCurrent = String(str[str.startIndex ..< (str.index(str.startIndex, offsetBy: 5))])
                    }
                    usleep(1000000)
                }
                catch {
                }
            }
        }
        DispatchQueue.global(qos: .background).async {
            while (self.operations.isMonitoring) {
                
                let out = self.robotMonitor[1].read(information.joint_temperatures_json)
                do {
                    let json = try JSONSerialization.jsonObject(with: out as Data) as? [Any]
                    for i in 1...4 {
                        let str = "\(json?[i] ?? self.data.jointData[i - 1].jointTemp)"
                        guard str.count >= 4 else {continue}
                        self.data.jointData[i - 1].jointTemp = String(str[str.startIndex ..< (str.index(str.startIndex, offsetBy: 4))])
                    }
                    usleep(1000000)
                }
                catch {
                }
            }
        }
        DispatchQueue.global(qos: .background).async {
            while (self.operations.isMonitoring) {
                
                let out = self.robotMonitor[2].read(information.get_all_joint_positions_json)
                do {
                    let json = try JSONSerialization.jsonObject(with: out as Data) as? [[Any]]
                    for i in 1...4 {
                        var j = 0
                        for pos in json?[i] as! [NSNumber] {
                            self.data.jointData[i - 1].position[j] = "\(pos)"
                            j += 1
                        }
                    }
                    usleep(30000)
                }
                catch {
                }
            }
        }
    }
    
}
