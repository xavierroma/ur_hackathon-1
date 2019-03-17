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

extension ViewController{
    
    @objc func handleTap(gestureRecognize: UITapGestureRecognizer) {
        // node.position = worldCoord
        
        if (baseTransform != nil) {
            if nodeHolder.parent != nil {
                nodeHolder.removeFromParentNode()
            }
            nodeHolder = SCNNode()
            nodeHolder.transform = SCNMatrix4(baseTransform.transform)
            nodeHolder.transform.m21 = 0.0;
            nodeHolder.transform.m22 = 1.0;
            nodeHolder.transform.m23 = 0.0;
            
            let scene = SCNScene(named: "art.scnassets/ship.scn")!
            for nodeInScene in scene.rootNode.childNodes as [SCNNode] {
                nodeHolder.addChildNode(nodeInScene)
            }
            let chartNode = ChartCreator.createBarChart(at:
                SCNVector3(baseTransform.transform.columns.3.x, baseTransform.transform.columns.3.y, baseTransform.transform.columns.3.z))
            chartNode.position.x += 0.5
            chartNode.position.z -= 0.5
            sceneView.scene.rootNode.addChildNode(chartNode)
            sceneView.scene.rootNode.addChildNode(nodeHolder)
        } else {
            statusViewController.showMessage("Unable to detect start position", autoHide: true)
        }
        
    }
    
    
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
