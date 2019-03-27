//
//  RobotMonitoring.swift
//  URApp
//
//  Created by XavierRoma on 27/03/2019.
//  Copyright © 2019 x.roma_gabriel.cammany. All rights reserved.
//

import Foundation
import SwiftSocket

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
            break
        }
    }
    
    func send(_ msg: String) {
        switch client.send(string: msg) {
        case .success:
            print("Message sent: \(msg)")
            print("listened: \(client.read(1024))")
            break
            
        case .failure(let error):
            print(error)
            break
        }
        
    }
    
    
}
