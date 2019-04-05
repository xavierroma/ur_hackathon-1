//
//  ViewController+SetUp.swift
//  URApp
//
//  Created by XavierRoma on 17/03/2019.
//  Copyright © 2019 x.roma_gabriel.cammany. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import MessageUI
import WebKit

extension ViewController{
    
    private func registerGestureRecognizers() {
        
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation))
        self.sceneView.addGestureRecognizer(rotationGestureRecognizer)
        
        let gesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture))
        // Set the delegate to ensure this gesture is only used when there are no virtual objects in the scene.
        sceneView.addGestureRecognizer(gesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panHandler))
        sceneView.addGestureRecognizer(panGesture)
    }
    
    /// Configures & Runs The ARSession
    func setupARSession(){
        
        //1. Setup Our Tracking Images
        guard let trackingImages =
            ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else { return }
        
        nodeHolder = nil
        
        
        
        configuration.detectionImages = trackingImages
        configuration.maximumNumberOfTrackedImages = trackingImages.count
        configuration.worldAlignment = .gravityAndHeading;
        configuration.planeDetection = [.horizontal]
        if #available(iOS 12.0, *) {
            configuration.environmentTexturing = .automatic
        }
        sceneView.delegate = self
        sceneView.debugOptions = [ .showFeaturePoints ]
        sceneView.session.run(configuration, options: [.resetTracking])
        
        registerGestureRecognizers()
        
        self.statusViewController.scheduleMessage("Find the robot workarea", inSeconds: 1.5, messageType: .planeEstimation)
        self.sceneView.scene.rootNode.addChildNode(self.focusSquare)
        
    }
    
    func restartExperience() {
        
        nodeHolder.removeFromParentNode()
        statusViewController.cancelAllScheduledMessages()
        self.statusViewController.scheduleMessage("Restarting...", inSeconds: 1.5, messageType: .planeEstimation)
        setupARSession()
        settings = Settings()
        operations = Operations()
        robotMonitor[0].close()
        robotMonitor[1].close()
        robotMonitor[2].close()
        robotMonitor[0] = RobotMonitoring(settings.robotIP, Int32(settings.robotPort))
        robotMonitor[1] = RobotMonitoring(settings.robotIP, Int32(settings.robotPort))
        robotMonitor[2] = RobotMonitoring(settings.robotIP, Int32(settings.robotPort))
        operations.isSettingPosition = true
        okCalibrateButton.isHidden = false
        messageBox(messageTitle: "Calibrate", messageAlert: "Porfavor, localiza la mesa de trabajo del robot", messageBoxStyle: .alert, alertActionStyle: UIAlertAction.Style.default, completionHandler: {})
        
    }
    
    func setupCamera() {
        guard let camera = sceneView.pointOfView?.camera else {
            fatalError("Expected a valid `pointOfView` from the scene.")
        }
        
        /*
         Enable HDR camera settings for the most realistic appearance
         with environmental lighting and physically based materials.
         */
        camera.wantsHDR = true
        camera.exposureOffset = -1
        camera.minimumExposure = -1
        camera.maximumExposure = 3
    }
    
}


