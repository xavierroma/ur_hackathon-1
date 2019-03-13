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

//----------------------------------------------
//MARK: - UISideMenuNavigationControllerDelegate
//----------------------------------------------


//-------------------------------------------
//MARK: - MFMailComposeViewControllerDelegate
//-------------------------------------------



//--------------------------
//MARK: -  ARSessionDelegate
//--------------------------

extension ViewController: ARSessionDelegate{
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors{
            
            if let imageAnchor = anchor as? ARImageAnchor, imageAnchor == targetAnchor{
                
                let referenceImage = imageAnchor.referenceImage
                
                switch(referenceImage.name){
                case "1":
                    if !imageAnchor.isTracked{
                        jointDetected[0] = false;
                    } else {
                        if !jointDetected[0] {
                            jointDetected[0] = true
                        }
                    }
                    break
                case "2":
                    if !imageAnchor.isTracked{
                        jointDetected[1] = false;
                    } else {
                        if !jointDetected[1] {
                            jointDetected[1] = true
                        }
                    }
                    break
                case "3":
                    if !imageAnchor.isTracked{
                        jointDetected[2] = false;
                    }
                    break
                default: ()
                }
                
            }
        }
     }
}
/*
 
 
 [-0.8899576, 0.19860172, 0.41052783, 0.0)],
 [0.16984218, 0.9797757, -0.10579764, 0.0)],
 [-0.42323676, -0.024430582, -0.9056897, 0.0)],
 [0.11519174, -0.080481924, 0.14731546, 0.9999999)
 
 simd_float4x4([
 [-0.90704966, 0.16027474, 0.38932392, 0.0)],
 [0.14567922, 0.9870643, -0.06694479, 0.0)],
 [-0.3950173, -0.004005847, -0.91866493, 0.0)],
 [0.08574996, -0.15792231, 0.12536956, 0.99999994)]
 ])
 
 simd_float4x4([
 [-0.41878417, 0.26280203, -0.8692267, 0.0)],
 [0.20042619, 0.9603514, 0.19378945, 0.0)],
 [0.88569134, -0.09305983, -0.45485243, 0.0)],
 [0.05944062, -0.20435002, 0.090059355, 1.0)]
 */


extension ViewController: ARSCNViewDelegate{
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        DispatchQueue.main.async {
            //If f
            self.updateFocusSquare(isObjectVisible: false)
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        //1. Check We Have A Valid Image Anchor
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        
        //2. Get The Detected Reference Image
        let referenceImage = imageAnchor.referenceImage
        
        switch(referenceImage.name){
        case "1":
            if jointDetected[0] { return }
            jointDetected[0] = true;
            node.addChildNode(joint)
            self.baseTransform = anchor
            targetAnchor = imageAnchor
            break
        case "2":
            if jointDetected[1] { return }
            jointDetected[1] = true;
            node.addChildNode(joint)
            self.baseTransform = anchor
            targetAnchor = imageAnchor
            break
        case "3":
            if jointDetected[2] { return }
            jointDetected[2] = true;
            let scene = SCNScene(named: "art.scnassets/ship.scn")!
            node.addChildNode(scene.rootNode)
            targetAnchor = imageAnchor
            break
        default: ()
        }
        
    }
    
    /*func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let currentImageAnchor = anchor as? ARImageAnchor else { return }
        
        //2. An ImageAnchor Is Only Added Once For Each Identified Target
        print("Anchor ID = \(currentImageAnchor.identifier)")
        
        //3. Add An SCNNode At The Position Of The Identified ImageTarget
        nodeHolder = SCNNode()
        //sceneView.session.add(anchor: ARAnchor(name: "test", transform: anchor.transform))
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        for nodeInScene in scene.rootNode.childNodes as [SCNNode] {
            nodeHolder.addChildNode(nodeInScene)
        }
    
        nodeHolder.position = SCNVector3(currentImageAnchor.transform.columns.3.x,
                                         currentImageAnchor.transform.columns.3.y,
                                         currentImageAnchor.transform.columns.3.z)
        nodeHolder.simdRotation = simd_float4(0,0,0,90);
        
        sceneView?.scene.rootNode.addChildNode(nodeHolder)
        
        
    }
     */
}
