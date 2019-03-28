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
import WebKit

extension ViewController: ARSCNViewDelegate{
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        DispatchQueue.main.async {
            self.updateFocusSquare(isObjectVisible: false)
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let imageAnchor = anchor as? ARImageAnchor,
            let result = sceneView.hitTest(screenCenter, types: [.estimatedHorizontalPlane]).first
            else { return }
        
        switch imageAnchor.name {
        case "1":
            statusViewController.showMessage("Posición de inicio encontrada!", autoHide: true)
            if nodeHolder != nil, nodeHolder.parent != nil {
                nodeHolder.removeFromParentNode()
            }
            nodeHolder = SCNNode()
            nodeHolder.transform = SCNMatrix4(anchor.transform)
            nodeHolder.transform.m21 = 0.0
            nodeHolder.transform.m22 = 1.0
            nodeHolder.transform.m23 = 0.0
            nodeHolder.transform.m42 = result.worldTransform.columns.3.y
            
            let scene2 = SCNScene(named: "art.scnassets/lightning.scn")!
            for nodeInScene in scene2.rootNode.childNodes as [SCNNode] {
                nodeHolder.addChildNode(nodeInScene)
            }
            
            let scene = SCNScene(named: "art.scnassets/ship.scn")!
            for nodeInScene in scene.rootNode.childNodes as [SCNNode] {
                nodeHolder.addChildNode(nodeInScene)
            }
            
            sceneView.scene.rootNode.addChildNode(nodeHolder)
            break
        case "2":
            
            break
        case "3":
            
            break
        default:
            break
        }
        
        
    }
    
}
