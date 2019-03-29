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
        node.opacity = 0.1
        node.name = "Joint-1"
        jointsBalls.append(node)
        node = SCNNode(geometry: SCNSphere(radius: 0.05))
        node.opacity = 0.1
        node.name = "Joint-2"
        jointsBalls.append(node)
        node = SCNNode(geometry: SCNSphere(radius: 0.05))
        node.opacity = 0.1
        node.name = "Joint-3"
        jointsBalls.append(node)
        node = SCNNode(geometry: SCNSphere(radius: 0.05))
        node.name = "Joint-4"
        node.opacity = 0.1
        jointsBalls.append(node)
        node = SCNNode(geometry: SCNSphere(radius: 0.05))
        node.opacity = 0.1
        node.name = "Joint-5"
        jointsBalls.append(node)
        node = SCNNode(geometry: SCNSphere(radius: 0.05))
        node.opacity = 0.1
        node.name = "Joint-6"
        jointsBalls.append(node)
        for joint in jointsBalls {
            self.nodeHolder.addChildNode(joint)
        }
        operations.isMonitoring = true
        DispatchQueue.global(qos: .background).async {
            while (self.operations.isMonitoring) {
                let joints = Utilities.cleanString(str: self.robotMonitor.read(information.get_all_joint_positions))
                if (joints.count != 6) {
                    continue
                }
                self.jointsInfo = joints
                usleep(25000)
            }
        }
    }
    
}
