//
//  RTDE.swift
//  speech_hack
//
//  Created by Guillem Garrofé Montoliu on 14/02/2019.
//  Copyright © 2019 Guillem Garrofé Montoliu. All rights reserved.
//

import Foundation

class RTDE {
    var size: Int32
    var time: Double
    var q_target = Array<Double>(repeating: 0.0, count: 6)
    var qd_target = Array<Double>(repeating: 0.0, count: 6)
    var qdd_target = Array<Double>(repeating: 0.0, count: 6)
    var i_target = Array<Double>(repeating: 0.0, count: 6)
    var m_target = Array<Double>(repeating: 0.0, count: 6)
    var q_actual = Array<Double>(repeating: 0.0, count: 6)
    var qd_actual = Array<Double>(repeating: 0.0, count: 6)
    var i_actual = Array<Double>(repeating: 0.0, count: 6)
    var i_control = Array<Double>(repeating: 0.0, count: 6)
    var tool_vector_actual = Array<Double>(repeating: 0.0, count: 6)
    var tcp_speed_actual = Array<Double>(repeating: 0.0, count: 6)
    var tcp_force = Array<Double>(repeating: 0.0, count: 6)
    var tool_vector_target = Array<Double>(repeating: 0.0, count: 6)
    var tcp_speed_target = Array<Double>(repeating: 0.0, count: 6)
    var digital_input = Array<Double>(repeating: 0.0, count: 6)
    var motor_temp = Array<Double>(repeating: 0.0, count: 6)
    var controller_timer = Array<Double>(repeating: 0.0, count: 6)
    var test_value = Array<Double>(repeating: 0.0, count: 6)
    var robot_mode = Array<Double>(repeating: 0.0, count: 6)
    var joint_modes = Array<Double>(repeating: 0.0, count: 6)
    var safety_mode = Array<Double>(repeating: 0.0, count: 6)
    var aux = Array<Double>(repeating: 0.0, count: 6)
    var tool_accelerometer = Array<Double>(repeating: 0.0, count: 6)
    var aux_2 = Array<Double>(repeating: 0.0, count: 6)
    var speed_scaling = Array<Double>(repeating: 0.0, count: 6)
    var linear_mom = Array<Double>(repeating: 0.0, count: 6)
    var aux_3 = Array<Double>(repeating: 0.0, count: 6)
    var aux_4 = Array<Double>(repeating: 0.0, count: 6)
    var v_main = Array<Double>(repeating: 0.0, count: 6)
    var v_robot = Array<Double>(repeating: 0.0, count: 6)
    var i_robot = Array<Double>(repeating: 0.0, count: 6)
    var v_actual = Array<Double>(repeating: 0.0, count: 6)
    var dig_outputs = Array<Double>(repeating: 0.0, count: 6)
    var program_state = Array<Double>(repeating: 0.0, count: 6)
    var elbow_pos = Array<Double>(repeating: 0.0, count: 6)
    var elbow_vel = Array<Double>(repeating: 0.0, count: 6)
    
    
    init () {
        size = 0
        time = 0.0
    }
}
