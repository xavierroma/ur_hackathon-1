//
//  RobotComunication.swift
//  speech_hack
//
//  Created by Guillem Garrofé Montoliu on 10/01/2019.
//  Copyright © 2019 Guillem Garrofé Montoliu. All rights reserved.
//

import SwiftSocket

class RobotComunication {
    
    let ip = "192.168.1.40"
    //let ip = "10.0.47.136"
    let port = 30002
    //let serverPort = 30040
    
    let positions = ["[-0.123, -0.179, 0.441, 2.031, -1.836, 0.498]", "[-0.088, -1, 0.377, 2.031, -1.836, 0.498]", "[-0.42385, 0.18968, -0.17430, 1.31170, 2.84970, 0.068]", "[-0.123, -0.179, 0.441, 2.031, -1.836, 0.498]", "[0.2, 0, -1.57, 0, 0, -2]"]
    
    //var positions = Array<String>()
    var client: TCPClient
    //var server: TCPServer
    var init_succeed = false
    var freeDrive: Bool
    
    init() {
        client = TCPClient(address: ip, port: Int32(port))
        //server = TCPServer(address: ip, port: Int32(serverPort))
        freeDrive = false
        
        connect()
        
        /*let thread_server = DispatchQueue(label: "thread_server")
        
        thread_server.async {
            self.socket_server()
        }*/
        //let thread_server = Thread(target: self, selector: "socket_server:", object: nil)
        //thread_server.start()
    }
    /*
    func robot_client() {
        self.send("def connect_to_ios():\n")
            self.send("s = socket_open(\"172.0.0.1\", \(serverPort), \"socket_robot\")\n")
            self.send("while s == False:\n")
                self.send("s = socket_open(\"172.0.0.1\", \(serverPort), \"socket_robot\")\n")
                self.send("Wait: 0.5\n")
            self.send("end\n")
        self.send("end\n")
        self.send("s.send(\"HOLA\")\n")
    }
    
    func socket_server() {
        
        switch server.listen() {
        case .success:
            
            //Connecting from the robot, this way we can send data from there
            let thread_robot = DispatchQueue(label: "thread_robot")
            
            thread_robot.async {
                self.robot_client()
            }
            
            if let dserver = server.accept() {
                print("Rebo: \(dserver.read(4))")
            }
            
            //Accept the connexion from the robot
            /*while true {
                if let client = server.accept() {
                    print("Rebo: \(client.read(4))")
                } else {
                    print("accept error")
                }
            }*/
        case .failure(let error):
            print(error)
        }
        
    }
    */
    
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
    
    func movel_to(_ position: Position) {
        stopMovement()
        send("movel(\(position.position), a=\(position.acc), v=\(position.vel), t=\(position.time), r=\(position.radius))\n")
    }
    
    func movep_to(_ position: Position) {
        stopMovement()
        send("movep(\(position.position), a=\(position.acc), v=\(position.vel), r=\(position.radius))\n")
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
