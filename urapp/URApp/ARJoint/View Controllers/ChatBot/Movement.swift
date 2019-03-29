//
//  Movement.swift
//  speech_hack
//
//  Created by Guillem Garrofé Montoliu on 11/02/2019.
//  Copyright © 2019 Guillem Garrofé Montoliu. All rights reserved.
//

import Foundation

class Movement {
    
    public static let MOVE_DEFAULT = "1"
    public static let DANCE = "2"
    public static let MOVE_DIRECTION = "3"
    public static let FREEDRIVE = "4"
    public static let STOP = "5"
    public static let GET_MOVEMENTS = "7"
    public static let DO_MOVEMENT = "8"
    public static let START_PROGRAMMING = "9"
    public static let PROGRAM_NAME = "10"
    public static let SHOW_WALLS = "11"
    public static let HIDE_WALLS = "12"
    
    public static let DIRECTION_UP = "arriba"
    public static let DIRECTION_DOWN = "abajo"
    public static let DIRECTION_RIGHT = "derecha"
    public static let DIRECTION_LEFT = "izquierda"
    public static let DIRECTION_STRAIGHT = "delante"
    public static let DIRECTION_BACK = "atrás"
    public static let DIRECTION_WAIT = "espera"
    
    public static let AMMOUNT_MUCH = "mucho"
    public static let AMMOUNT_LITTLE = "poco"
    public static let AMMOUNT_DEFAULT = "default"
    
    private var com: RobotComunication
    
    private var programming: Bool
    private var programName: String?
    
    let dance_poses = ["[-2.52, -2.26, -0.22, -1.42, -0.06, 0.77]",
                       "[-2.49, -2.19, 1.25, -1.42, -0.06, 0.77]",
                       "[-2.52, -2.26, -0.22, -1.42, -0.06, 0.77]",
                       "[-2.49, -2.19, 1.25, -1.42, -0.06, 0.77]",
                       "[-0.93, -1.94, -1.68, -3.06, -1.49, 0.89]"]
    
    init (_ com: RobotComunication) {
        self.com = com
        self.programming = false
        self.programName = nil
    }
    
    func dance() {
        com.send("def M():\n")
        com.send("  move = True\n")
        com.send("  while move:\n")
        var i = 0;
        for pose in dance_poses {
            com.movej_to(Position(pose, "1.8", "1.4", "0", "0", "0"))
            i += 1;
            com.send("  while is_steady() == False:\n")
            com.send("      sleep(0.01)\n")
            com.send("  end\n")
        }
        com.send("  end\n")
        com.send("end\n")
    }
    
    func stopMovement() {
        com.send("move = False\n")
    }
    
    func originPoint() {
        com.movej_to(Position("[-1.58, -1.06, -1.2, -1.54, 1.59, 0.775]"))
    }
    
    func freedrive() {
        com.freedrive(true)
    }
    
    func stopFreedrive() {
        com.freedrive(false)
    }
    
    func moveRight(ammount: String) {
        let amm = (ammount == Movement.AMMOUNT_MUCH) ? 0.3 :
            (ammount == Movement.AMMOUNT_LITTLE) ? 0.1 : 0.05
        
        com.movel_to(Position("pose_add(get_actual_tcp_pose(), p[\(amm), 0, 0, 0, 0, 0])"))
        print("moving right")
    }
    
    func moveLeft(ammount: String) {
        let amm = (ammount == Movement.AMMOUNT_MUCH) ? -0.3 :
            (ammount == Movement.AMMOUNT_LITTLE) ? -0.1 : -0.2
        
        com.movej_to(Position("pose_add(get_actual_tcp_pose(), p[\(amm), 0, 0, 0, 0, 0])"))
        print("moving left")
    }
    
    func moveUp(ammount: String) {
        let amm = (ammount == Movement.AMMOUNT_MUCH) ? 0.3 :
            (ammount == Movement.AMMOUNT_LITTLE) ? 0.1 : 0.2
        
        com.movej_to(Position("pose_add(get_actual_tcp_pose(), p[0, 0, \(amm), 0, 0, 0])"))
        print("moving up")
    }
    
    func moveDown(ammount: String) {
        let amm = (ammount == Movement.AMMOUNT_MUCH) ? -0.3 :
            (ammount == Movement.AMMOUNT_LITTLE) ? -0.1 : -0.2
        
        com.movej_to(Position("pose_add(get_actual_tcp_pose(), p[0, 0, \(amm), 0, 0, 0])"))
        print("moving down")
    }
    
    func moveStraight(ammount: String) {
        let amm = (ammount == Movement.AMMOUNT_MUCH) ? -0.3 :
            (ammount == Movement.AMMOUNT_LITTLE) ? -0.1 : -0.2
        
        com.movej_to(Position("pose_add(get_actual_tcp_pose(), p[0, \(amm), 0, 0, 0, 0])"))
        print("moving straight")
    }
    
    func moveBack(ammount: String) {
        let amm = (ammount == Movement.AMMOUNT_MUCH) ? 0.3 :
            (ammount == Movement.AMMOUNT_LITTLE) ? 0.1 : 0.2
        
        com.movej_to(Position("pose_add(get_actual_tcp_pose(), p[0, \(amm), 0, 0, 0, 0])"))
        print("moving back")
    }
    
    func startMovement(_ poses: Array<String>) {
        
        com.send("def M():\n")
        com.send("  move = True\n")
        com.send("  while move:\n")
        for pose in poses{
            com.movej_to(Position(pose))
            com.send("  while is_steady() == False:\n")
            com.send("      sleep(0.01)\n")
            com.send("  end\n")
        }
        com.send("  end\n")
        com.send("end\n")
    }
    
    func startProgramming() {
        programming = true
    }
    
    func stopProgramming() {
        programming = false
        self.programName = nil
    }
    
    func isProgramming() -> Bool {
        return self.programming
    }
    
    func saveName(_ name: String) {
        self.programName = name
    }
    
    //TODO es podria fer una funció que et retornés la quantitat que cal moure's.
    //Només si en tots els casos és el mateix, sinó no val la pena
}
