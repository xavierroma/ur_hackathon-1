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
        
        var node = SCNNode(geometry: SCNSphere(radius: 0.05))
        node.opacity = 0.1
        node.name = "Joint-0"
        jointsBalls.append(node)
        node = SCNNode(geometry: SCNSphere(radius: 0.05))
        node.name = "Joint-1"
        jointsBalls.append(node)
        node = SCNNode(geometry: SCNSphere(radius: 0.05))
        node.name = "Joint-2"
        jointsBalls.append(node)
        node = SCNNode(geometry: SCNSphere(radius: 0.05))
        node.name = "Joint-3"
        jointsBalls.append(node)
        node = SCNNode(geometry: SCNSphere(radius: 0.05))
        node.name = "Joint-4"
        node.opacity = 0.1
        jointsBalls.append(node)
        node = SCNNode(geometry: SCNSphere(radius: 0.05))
        node.name = "Joint-5"
        jointsBalls.append(node)
        node = SCNNode(geometry: SCNSphere(radius: 0.05))
        node.name = "Joint-6"
        jointsBalls.append(node)
        
        
         for joint in jointsBalls {
            self.nodeHolder.addChildNode(joint)
        }
        DispatchQueue.global(qos: .background).async {
        
            while (true) {
                let joints = self.cleanString(str: self.robotMonitor.read(information.get_all_joint_positions))
                if (joints.count != 6) {
                    continue
                }
                
                for i in 0...5 {
                    self.jointsBalls[i].transform.m41 = (Float(joints[i][0]) ?? self.jointsBalls[i].transform.m41) - 0.085
                    self.jointsBalls[i].transform.m42 = (Float(joints[i][2]) ?? self.jointsBalls[i].transform.m42) + 0.18
                    self.jointsBalls[i].transform.m43 = (Float(joints[i][1]) ?? self.jointsBalls[i].transform.m43) * -1 - 0.325
                    // SCNVector3(Double(pos[0])! - 0.085, Double(pos[2])! + 0.18, Double(pos[1])! * -1 - 0.325)
                    
                }
                usleep(50000)
                
            }
        }
    }
    
}
