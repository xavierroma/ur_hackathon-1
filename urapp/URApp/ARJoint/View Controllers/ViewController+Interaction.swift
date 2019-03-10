//
//  ViewController.swift
//  test
//
//  Created by XavierRoma on 08/03/2019.
//  Copyright © 2019 Salle URL. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import MessageUI
import WebKit
import Contacts

extension ViewController{
    
    //-----------------------
    //MARK: - UserInteraction
    //-----------------------
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //1. Get The Current Touch Location & Perform An SCNHitTest To Detect Which Nodes We Have Touched
        guard let currentTouchLocation = touches.first?.location(in: self.augmentedRealityView),
            let hitTestResult = self.augmentedRealityView.hitTest(currentTouchLocation, options: nil).first?.node.name
            else { return }
        
        //2. Perform The Neccessary Action Based On The Hit Node
        switch(hitTestResult) {
        case "speed":
            print("Speed")
            break
        case "more":
            displayWebSite()
            break
        case "temp":
            print("Temperature")
            break
        default:()
        }
    }
    
    
    
    func displayWebSite() {
        self.performSegue(withIdentifier: "webViewer", sender: nil)
        
    }
    
    func handleProgrammingMode(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
    }
    
    
    func createBall(position : SCNVector3) {
        var ball = SCNSphere(radius: 0.01);
        
        var ballNode = SCNNode(geometry: ball)
        ballNode.position = position
        print("bola\n")
        augmentedRealityView.scene.rootNode.addChildNode(ballNode)
        
    }
    
    
  
    
}
