//
//  RobotComunication.swift
//  speech_hack
//
//  Created by Guillem Garrofé Montoliu on 10/01/2019.
//  Copyright © 2019 Guillem Garrofé Montoliu. All rights reserved.
//

import SwiftSocket

class RobotComunication {
    
    let ip = "127.0.0.1"
    let port = 30001
    let positions = ["[0.2, 0.3, 0.5, 0, 0, 3.14]", "[2, 0.5, 3, 0, 0, -2]", "[0.2, 0, -1.57, 0, 0, -2]"]
    var client: TCPClient
    
    init() {
        client = TCPClient(address: ip, port: Int32(port))
        
        switch client.connect(timeout: 10) {
            case .success:
                print("Connected to \(ip) : \(port)")
                movel_to()
                break
            
            case .failure(let error):
                print(error)
                break
        }
    }
    
    func movel_to() {
        let command = "movel(\(positions[0]), a=1.2, v=0.25, t=0, r=0)\n"
        print("Sending: \(command)")
        
        switch client.send(string: command) {
            case .success:
                
                guard let data = client.read(1024*10) else { return }
                print(data)
                break
            
            case .failure(let error):
                print(error)
                break
        }
    }
    
    
    
}
