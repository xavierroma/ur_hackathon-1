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
    //let positions = ["[0.2, 0.3, 0.5, 0, 0, 3.14]", "[2, 0.5, 3, 0, 0, -2]", "[0.2, 0, -1.57, 0, 0, -2]"]
    var positions = Array<String>()
    var client: TCPClient
    var init_succeed: Bool
    
    init() {
        client = TCPClient(address: ip, port: Int32(port))
        
        switch client.connect(timeout: 10) {
            case .success:
                print("Connected to \(ip) : \(port)")
                init_succeed = true
                break
            
            case .failure(let error):
                print(error)
                init_succeed = false
                break
        }
    }
    
    func movel_to(_ position: Position) {
        let command = "movel(\(position.position), a=\(position.acc), v=\(position.vel), t=\(position.time), r=\(position.radius)\n"
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
    
    func movep_to(_ position: Position) {
        let command = "movep(\(position.position), a=\(position.acc), v=\(position.vel), r=\(position.radius)\n"
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
    
    func movej_to(_ position: Position) {
        let command = "movej(\(position.position), a=\(position.acc), v=\(position.vel), t=\(position.time), r=\(position.radius)\n"
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
