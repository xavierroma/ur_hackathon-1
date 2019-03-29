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
        
        jointsBalls.append( SCNNode(geometry: SCNSphere(radius: 0.01)))
        jointsBalls.append( SCNNode(geometry: SCNSphere(radius: 0.01)))
        jointsBalls.append( SCNNode(geometry: SCNSphere(radius: 0.01)))
        jointsBalls.append( SCNNode(geometry: SCNSphere(radius: 0.01)))
        jointsBalls.append( SCNNode(geometry: SCNSphere(radius: 0.01)))
        jointsBalls.append( SCNNode(geometry: SCNSphere(radius: 0.01)))
         for joint in jointsBalls {
            self.nodeHolder.addChildNode(joint)
        }
        DispatchQueue.global(qos: .background).async {
        
            while (true) {
                let joints = self.cleanString(str: self.robotMonitor.read(information.get_all_joint_positions))
                var i = 0
                for pos in joints {
                    self.jointsBalls[i].transform.m41 = Float(pos[0])! - 0.085
                    self.jointsBalls[i].transform.m42 = Float(pos[2])! + 0.18
                    self.jointsBalls[i].transform.m43 = Float(pos[1])! * -1 - 0.325
                       // SCNVector3(Double(pos[0])! - 0.085, Double(pos[2])! + 0.18, Double(pos[1])! * -1 - 0.325)
                    
                    i+=1
                }
                usleep(100000)
                
            }
        }
    }
    
}
