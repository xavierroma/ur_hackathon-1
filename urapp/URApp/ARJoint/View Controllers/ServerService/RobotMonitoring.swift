//
//  RobotMonitoring.swift
//  URApp
//
//  Created by XavierRoma on 27/03/2019.
//  Copyright © 2019 x.roma_gabriel.cammany. All rights reserved.
//

import Foundation
import SwiftSocket


enum information: String {
    typealias RawValue = String
    case timestamp = "timestamp";
    case target_q = "target_q";
    case target_qd = "target_qd";
    case target_qdd = "target_qdd";
    case target_current = "target_current";
    case target_moment = "target_moment";
    case actual_q = "actual_q";
    case actual_qd = "actual_qd";
    case actual_current =  "actual_current";
    case joint_control_output = "joint_control_output";
    case actual_TCP_pose = "actual_TCP_pose";
    case actual_TCP_speed = "actual_TCP_speed";
    case actual_TCP_force = "actual_TCP_force";
    case target_TCP_pose = "target_TCP_pose";
    case target_TCP_speed = "target_TCP_speed";
    case actual_digital_input_bits = "actual_digital_input_bits";
    case joint_temperatures = "joint_temperatures";
    case actual_execution_time = "actual_execution_time";
    case robot_mode = "robot_mode";
    case joint_mode = "joint_mode";
    case safety_mode = "safety_mode";
    case actual_tool_accelerometer = "actual_tool_accelerometer";
    case speed_scaling = "speed_scaling";
    case target_speed_fraction = "target_speed_fraction";
    case actual_momentum = "actual_momentum";
    case actual_main_voltage = "actual_main_voltage";
    case actual_robot_voltage = "actual_robot_voltage";
    case actual_robot_current = "actual_robot_current";
    case actual_joint_voltage = "actual_joint_voltage";
    case actual_digital_output_bits = "actual_digital_output_bits";
    case runtime_state = "runtime_state";
    case get_all_joint_positions = "get_all_joint_positions";
}

class RobotMonitoring {
    
    var client: TCPClient
    
    var init_succeed = false
    var freeDrive: Bool
    
    init(_ ip: String,_ port: Int32) {
        client = TCPClient(address: ip, port: port)
        //server = TCPServer(address: ip, port: Int32(serverPort))
        freeDrive = false
        
        connect()
        
    }
    
    func close() {
        client.close()
    }
    
    func connect(){
        switch client.connect(timeout: 10) {
        case .success:
            init_succeed = true
            break
            
        case .failure(let error):
            print(error)
            init_succeed = false
            client.close()
            break
        }
    }
    
    func read(_ what: information) -> String {
        
        switch client.send(string: what.rawValue) {
        case .success:
            guard let bytes = client.read(1024) else {return ""}
            let responseString = NSString(bytes: bytes, length: bytes.count, encoding: String.Encoding.utf8.rawValue)! as String
            return responseString
   
        case .failure(let error):
            print(error)
            break
        }
        return ""
    }
    
    
}
