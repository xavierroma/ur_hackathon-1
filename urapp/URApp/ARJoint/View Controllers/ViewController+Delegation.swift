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

        //1. Enumerate Our Anchors To See If We Have Found Our Target Anchor
        for anchor in anchors{

            if let imageAnchor = anchor as? ARImageAnchor, imageAnchor == targetAnchor{

                let referenceImage = imageAnchor.referenceImage
                
                switch(referenceImage.name){
                case "1":
                     if !imageAnchor.isTracked{
                        jointDetected[0] = false;
                     } else {
                        if !jointDetected[0] {
                            joint.setBaseConfiguration()
                            joint.animateBusinessCard()
                            jointDetected[0] = true
                        }
                     }
                    break
                case "2":
                    if !imageAnchor.isTracked{
                        jointDetected[1] = false;
                    } else {
                        if !jointDetected[1] {
                            joint.setBaseConfiguration()
                            joint.animateBusinessCard()
                            jointDetected[1] = true
                        }
                    }
                    break
                case "3":
                    if !imageAnchor.isTracked{
                        jointDetected[2] = false;
                    } else {
                        if !jointDetected[2] {
                            jointBase.setBaseConfiguration()
                            jointBase.animateBusinessCard()
                            jointDetected[2] = true
                        }
                    }
                    break
                default: ()
                }
            
            }
        }
     }
}

extension ViewController: ARSCNViewDelegate{
    
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
                joint.animateBusinessCard()
                targetAnchor = imageAnchor
                break
            case "2":
                 if jointDetected[1] { return }
                jointDetected[1] = true;
                node.addChildNode(joint)
                joint.animateBusinessCard()
                targetAnchor = imageAnchor
                break
            case "3":
                 if jointDetected[2] { return }
                jointDetected[2] = true;
                node.addChildNode(jointBase)
                jointBase.animateBusinessCard()
                targetAnchor = imageAnchor
                break
            default: ()
        }
        
    }
}
