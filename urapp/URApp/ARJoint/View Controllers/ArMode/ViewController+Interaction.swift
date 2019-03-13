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
        guard let currentTouchLocation = touches.first?.location(in: self.sceneView),
            let hitTestResult = self.sceneView.hitTest(currentTouchLocation, options: nil).first?.node.name
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

// MARK: - Update object position

/// - Tag: DragVirtualObject
func translate(_ object: SCNScene, basedOn screenPos: CGPoint, infinitePlane: Bool, allowAnimation: Bool) {
    guard let cameraTransform = sceneView.session.currentFrame?.camera.transform,
        let result = sceneView.smartHitTest(screenPos,
                                            infinitePlane: infinitePlane,
                                            objectPosition: object.rootNode.simdWorldPosition,
                                            allowedAlignments: [ARPlaneAnchor.Alignment.horizontal]) else { return }
    
    let planeAlignment: ARPlaneAnchor.Alignment
    if let planeAnchor = result.anchor as? ARPlaneAnchor {
        planeAlignment = planeAnchor.alignment
    } else if result.type == .estimatedHorizontalPlane {
        planeAlignment = .horizontal
    } else if result.type == .estimatedVerticalPlane {
        planeAlignment = .vertical
    } else {
        return
    }
    
}

    func displayWebSite() {
        self.performSegue(withIdentifier: "webViewer", sender: nil)
        
    }
    
    func handleProgrammingMode(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
    }
    
}
