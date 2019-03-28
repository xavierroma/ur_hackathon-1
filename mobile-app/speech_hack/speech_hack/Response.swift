//
//  Response.swift
//  speech_hack
//
//  Created by Guillem Garrofé Montoliu on 12/02/2019.
//  Copyright © 2019 Guillem Garrofé Montoliu. All rights reserved.
//



import ApiAI
import Foundation

class Response {
    
    public static let MOVEMENT_ID = "movement-id"
    static let MOVEMENT = "robot-movement"
    static let DIRECTION = "robot-direction"
    static let AMMOUNT = "movement-ammount"
    static let PROGRAM_NAME = "program-name"
    
    var response: AIResponse
    var mov: Movement
    var parameters: NSMutableDictionary
    var movements: RobotMovements
    var vc: ChatViewController
    
    init(_ mov: Movement, _ response: AIResponse, _ movements: RobotMovements, _ vc: ChatViewController) {
        self.mov = mov
        self.response = response
        var parameters_aux =  response.result.parameters as! Dictionary<String, Any>
        parameters = NSMutableDictionary()
        
        for key in parameters_aux.keys {
            let aux = parameters_aux[key] as? AIResponseParameter;
            let value = aux!.stringValue
            parameters.setObject(value, forKey: key as NSCopying)
        }
        
        self.movements = movements
        self.vc = vc
        
        listParameters()
        print(response)
    }
    
    func listParameters () {
        print("Listing all the parameters:")
        for (key, value) in parameters {
            print( "\(key): \(value)")
        }
    }
    
    func getParameter(_ param: String) -> String {
        return parameters[param] as! String
    }
    
    func hasParameter(_ param: String) -> Bool {
        return (parameters[param] as! String?) != nil
    }
    
    func responseBehaviour() {
        if (hasParameter(Response.MOVEMENT_ID)) {
            //let com = RobotComunication()
            //mov = Movement(com)
            
            switch (getParameter(Response.MOVEMENT_ID)) {
            case Movement.MOVE_DEFAULT:
                mov.originPoint()
                
            case Movement.DANCE:
                mov.dance()
                
            case Movement.MOVE_DIRECTION:
                if (mov.isProgramming()) {
                    let message = response.result.fulfillment.messages[1]["speech"] as! String
                    vc.displayRobotResponse(message: message)
                    
                    //TODO guardar instrucció
                    
                } else {
                    let message = response.result.fulfillment.messages[0]["speech"] as! String
                    vc.displayRobotResponse(message: message)
                    self.moveDirection(mov)
                }
                
            case Movement.FREEDRIVE:
                mov.freedrive()
                
            case Movement.STOP:
                mov.stopFreedrive()
                mov.stopMovement()
            
            case Movement.GET_MOVEMENTS:
                var message = response.result.fulfillment.messages[0]["speech"] as! String
                for movement in movements.getMovementsList() {
                    message.append("\n")
                    message.append("- ")
                    message.append(movement)
                }
                vc.displayRobotResponse(message: message)
            
            case Movement.DO_MOVEMENT:
                if (movements.movementExists(self.getParameter(Response.MOVEMENT))) {
                    let message = response.result.fulfillment.messages[0]["speech"] as! String
                    vc.displayRobotResponse(message: message)
                    
                    mov.startMovement(movements.getMovement(self.getParameter(Response.MOVEMENT)).positions)
                    
                } else {
                    vc.displayRobotResponse(message: "El movimiento no se ha reconocido")
                }
                
            case Movement.START_PROGRAMMING:
                mov.startProgramming()
                
            case Movement.PROGRAM_NAME:
                var name = getParameter(Response.PROGRAM_NAME)
                
            case Movement.SHOW_WALLS:
                NotificationCenter.default.post(name: .showWalls, object: true)
                
            case Movement.HIDE_WALLS:
                NotificationCenter.default.post(name: .showWalls, object: false)
                
            default:
                print("unknown command")
            }
        }
    }
    
    func moveDirection(_ mov: Movement) {
        var amm = Movement.AMMOUNT_DEFAULT
        if (hasParameter(Response.AMMOUNT)) {
            amm = getParameter(Response.AMMOUNT)
        }
        
        switch (getParameter(Response.DIRECTION)) {
        case Movement.DIRECTION_UP:
            mov.moveUp(ammount: amm)
            
        case Movement.DIRECTION_DOWN:
            mov.moveDown(ammount: amm)
            
        case Movement.DIRECTION_LEFT:
            mov.moveLeft(ammount: amm)
            
        case Movement.DIRECTION_RIGHT:
            mov.moveRight(ammount: amm)
            
        case Movement.DIRECTION_STRAIGHT:
            mov.moveStraight(ammount: amm)
            
        case Movement.DIRECTION_BACK:
            mov.moveBack(ammount: amm)
            
        default:
            print("unknown direction")
        }
    }
}
