//
//  Position.swift
//  speech_hack
//
//  Created by Guillem Garrofé Montoliu on 05/02/2019.
//  Copyright © 2019 Guillem Garrofé Montoliu. All rights reserved.
//

import Foundation

class Position {
    var position: String
    var acc: String
    var vel: String
    var radius: String
    var time: String
    
    init(_ position: String) {
        self.position = position
        self.acc = "1.2"
        self.vel = "0.25"
        self.radius = "0"
        self.time = "0"
    }
    
    init(_ position: Int) {
        self.position = String(position)
        self.acc = "1.2"
        self.vel = "0.25"
        self.radius = "0"
        self.time = "0"
    }
    
    init(_ position: String, _ acc: String, _ vel: String, _ time: String, _ radius: String) {
        self.position = position
        self.acc = acc
        self.vel = vel
        self.radius = radius
        self.time = time
    }
}
