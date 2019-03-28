//
//  Response.swift
//  speech_hack
//
//  Created by Guillem Garrofé Montoliu on 12/02/2019.
//  Copyright © 2019 Guillem Garrofé Montoliu. All rights reserved.
//



import ApiAI
import Foundation
import CoreData

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
    
    var appDelegate: AppDelegate!
    var context: NSManagedObjectContext!
    
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
        
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
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
                if (mov.isProgramming()) {
                    mov.stopProgramming()
                    
                    let message = response.result.fulfillment.messages[1]["speech"] as! String
                    vc.displayRobotResponse(message: message)
                } else {
                    mov.stopFreedrive()
                    mov.stopMovement()
                    
                    let message = response.result.fulfillment.messages[0]["speech"] as! String
                    vc.displayRobotResponse(message: message)
                }
                
            
            case Movement.GET_MOVEMENTS:
                var message = response.result.fulfillment.messages[0]["speech"] as! String
                
                for mov in getMovementsList() {
                    message.append("\n")
                    message.append("- ")
                    message.append(mov.name!)
                }
                
                vc.displayRobotResponse(message: message)
            
            case Movement.DO_MOVEMENT:
                let movementInstructions = getMovement(name: self.getParameter(Response.MOVEMENT))
                if (movementInstructions.count > 0) {
                //if (movements.movementExists(self.getParameter(Response.MOVEMENT))) {
                    let message = response.result.fulfillment.messages[0]["speech"] as! String
                    vc.displayRobotResponse(message: message)
                    
                    mov.startMovement(movementInstructions)
                    
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
    
    
    func getMovementsList() -> Array<Mov> {
        let fr = NSFetchRequest<Mov>(entityName: "Mov")
        let _movements = try! context.fetch(fr)
        
        var movements = Array<Mov>()
        for movement in _movements {
            if (!isRegistered(movements: movements, mov: movement)) {
                movements.append(movement)
            }
        }
        
        return movements
    }
    
    func isRegistered(movements: Array<Mov>, mov: Mov) -> Bool {
        for movement in movements {
            if (movement.name!.caseInsensitiveCompare(mov.name!) == .orderedSame) {
                return true
            }
        }
        return false
    }
    
    func getMovement(name: String) -> Array<String> {
        let fr = NSFetchRequest<Mov>(entityName: "Mov")
        let _movements = try! context.fetch(fr)
        let movOrdered = _movements.sorted(by: {$0.order < $1.order})
        
        var movements = Array<String>()
        for movement in movOrdered {
            if (movement.name!.caseInsensitiveCompare(name) == .orderedSame) {
                if (movement.time != nil) {
                    //mirar el wait
                } else {
                movements.append("[\(movement.x!), \(movement.y!), \(movement.z!), \(movement.rx!), \(movement.ry!), \(movement.rz!)]")
                }
            }
        }
        
        
        return movements
    }
    
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
