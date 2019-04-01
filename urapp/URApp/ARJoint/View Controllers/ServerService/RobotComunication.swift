//
//  RobotComunication.swift
//  speech_hack
//
//  Created by Guillem Garrofé Montoliu on 10/01/2019.
//  Copyright © 2019 Guillem Garrofé Montoliu. All rights reserved.
//

import SwiftSocket

class RobotComunication {
    //let ip = "127.0.0.1"
    let ip = "192.168.1.40"
    //let ip = "10.0.47.136"
    let port = 30002
    let port_data = 30100
    let port_comm = 29999
    //let serverPort = 30040
    
    let positions = ["[-0.123, -0.179, 0.441, 2.031, -1.836, 0.498]", "[-0.088, -1, 0.377, 2.031, -1.836, 0.498]", "[-0.42385, 0.18968, -0.17430, 1.31170, 2.84970, 0.068]", "[-0.123, -0.179, 0.441, 2.031, -1.836, 0.498]", "[0.2, 0, -1.57, 0, 0, -2]"]
    
    //var positions = Array<String>()
    var client: TCPClient
    var data: TCPClient
    var commands: TCPClient
    //var server: TCPServer
    var init_succeed = false
    var freeDrive: Bool
    
    init() {
        client = TCPClient(address: ip, port: Int32(port))
        data = TCPClient(address: ip, port: Int32(port_data))
        commands = TCPClient(address: ip, port: Int32(port_comm))
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
            print("Connected to \(ip) : \(port)")
            init_succeed = true
            break
            
        case .failure(let error):
            print(error)
            init_succeed = false
            break
        }
        switch data.connect(timeout: 10) {
        case .success:
            print("Connected to \(ip) : \(port_data)")
            init_succeed = true
            sendData("actual_q")
            var recv = recvData()
            break
            
        case .failure(let error):
            print(error)
            init_succeed = false
            break
        }
        switch commands.connect(timeout: 10) {
        case .success:
            print("Connected to \(ip) : \(port_comm)")
            init_succeed = true
            break
            
        case .failure(let error):
            print(error)
            init_succeed = false
            break
        }
    }
    
    func send(_ msg: String) {
        switch client.send(string: msg) {
        case .success:
            print("Message sent: \(msg)")
            break
            
        case .failure(let error):
            print(error)
            break
        }
    }
    
    func sendData(_ msg: String) {
        switch data.send(string: msg) {
        case .success:
            print("Message sent: \(msg)")
            break
            
        case .failure(let error):
            print(error)
            break
        }
    }
    
    func sendCommand(_ msg: String) {
        switch commands.send(string: msg) {
        case .success:
            print("Command sent: \(msg)")
            break
            
        case .failure(let error):
            print(error)
            break
        }
    }
    
    func recvData() -> String {
        let response = data.read(1024)
        var resp: String = ""
        if (response != nil) {
            resp = String(bytes: response! , encoding: .utf8)!
        }
        return resp
    }
    
    func movel_to(_ position: Position) {
        stopMovement()
        send("movel(\(position.position), a=\(position.acc), v=\(position.vel), t=\(position.time), r=\(position.radius))\n")
    }
    
    func movej_to(_ position: Position) {
        stopMovement()
        send("movej(\(position.position), a=\(position.acc), v=\(position.vel), t=\(position.time), r=\(position.radius))\n")
    }
    
    func freedrive(_ on: Bool) {
        send("move = False\n")
        if(on && !freeDrive) {
            send("def P():\n")
            send("  fd = True\n")
            send("  while fd:\n")
            send("      freedrive_mode()\n")
            send("      sleep(0.01)\n")
            send("  end\n")
            send("end\n")
            freeDrive = true
        } else if(freeDrive){
            send("fd = False\n")
            freeDrive = false
        }
    }
    
    func servoj_to(_ position: Position) {
        stopMovement()
        send("servoj(\(position.position), a=\(position.acc), v=\(position.vel), t=\(position.time), lookahead_time=\(position.time), gain=\(position.gain))\n")
    }
    
    func servoc_to(_ position: Position) {
        stopMovement()
        send("servoc(\(position.position), a=\(position.acc), v=\(position.vel), r=\(position.radius))\n")
    }
    
    func stopMovement() {
        send("move = False\n")
        if (freeDrive) {
            self.freedrive(false)
            freeDrive = false
        }
    }
    
}
