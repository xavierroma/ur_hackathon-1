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

class ViewController: UIViewController {
 
    //@IBOutlet var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    @IBOutlet var sceneView: VirtualObjectARView!
    
    @IBOutlet weak var addObjectButton: UIButton!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var joint: Joint!
    var focusSquare = FocusSquare()
    var jointBase: Joint!
    var actionButtonsData: ActionButtonsData?
    var nodeHolder: SCNNode!
    var targetAnchor: ARImageAnchor?
    
    var baseTransform:  ARAnchor!
    
    /// Marks if the AR experience is available for restart.
    var isRestartAvailable = true
    
    lazy var statusViewController: StatusViewController = {
        return children.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()
    var jointDetected = [false,false,false]
    let updateQueue = DispatchQueue(label: "com.example.apple-samplecode.arkitexample.serialSceneKitQueue")
    var screenCenter: CGPoint {
        let bounds = sceneView.bounds
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    //----------------------
    //MARK: - View LifeCycle
    //----------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBusinessCard()
        setupARSession()
        setupCamera()
        sceneView.scene.rootNode.addChildNode(focusSquare)
        
        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
    }
    
    /// Creates a new AR configuration to run on the `session`.
    func resetTracking() {
       
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        if #available(iOS 12.0, *) {
            configuration.environmentTexturing = .automatic
        }
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        statusViewController.scheduleMessage("FIND A SURFACE TO PLACE AN OBJECT", inSeconds: 7.5, messageType: .planeEstimation)
    }
    
    func restartExperience() {
        guard isRestartAvailable else { return }
        isRestartAvailable = false
        
        statusViewController.cancelAllScheduledMessages()
        
       
        addObjectButton.setImage(#imageLiteral(resourceName: "add"), for: [])
        addObjectButton.setImage(#imageLiteral(resourceName: "addPressed"), for: [.highlighted])
        
        resetTracking()
        
        // Disable restart for a while in order to give the session time to restart.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.isRestartAvailable = true
        }
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

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        actionButtonsData = nil
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func displayErrorMessage(title: String, message: String) {
        // Blur the background.
        blurView.isHidden = false
        
        // Present an alert informing about the error that has occurred.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.blurView.isHidden = true
            self.resetTracking()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func updateFocusSquare(isObjectVisible: Bool) {
        if isObjectVisible {
            focusSquare.hide()
        } else {
            focusSquare.unhide()
            statusViewController.scheduleMessage("TRY MOVING LEFT OR RIGHT", inSeconds: 5.0, messageType: .focusSquare)
        }
        
        // Perform hit testing only when ARKit tracking is in a good state.
        if let camera = sceneView.session.currentFrame?.camera, case .normal = camera.trackingState,
            let result = self.sceneView.smartHitTest(screenCenter) {
            updateQueue.async {
                self.sceneView.scene.rootNode.addChildNode(self.focusSquare)
                self.focusSquare.state = .detecting(hitTestResult: result, camera: camera)
            }
          
            statusViewController.cancelScheduledMessage(for: .focusSquare)
        } else {
            updateQueue.async {
                self.focusSquare.state = .initializing
                self.sceneView.pointOfView?.addChildNode(self.focusSquare)
            }
            
        }
    }
    
    //---------------
    //MARK: - ARSetup
    //---------------
    
    /// Configures & Runs The ARSession
    func setupARSession(){
        
        //1. Setup Our Tracking Images
        guard let trackingImages =
            ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else { return }
        
        configuration.detectionImages = trackingImages
        configuration.maximumNumberOfTrackedImages = trackingImages.count
        configuration.worldAlignment = .gravityAndHeading;
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(gestureRecognize:)))
        view.addGestureRecognizer(tapGesture)
        
        sceneView.delegate = self
        sceneView.debugOptions = [ .showFeaturePoints ]
        sceneView.session.delegate = self
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    @objc func handleTap(gestureRecognize: UITapGestureRecognizer) {
        // HIT TEST : REAL WORLD
        // Get Screen Centre
        let screenCentre : CGPoint = CGPoint(x: self.sceneView.bounds.midX, y: self.sceneView.bounds.midY)
        
        let arHitTestResults : [ARHitTestResult] = sceneView.hitTest(screenCentre, types: [.featurePoint]) // Alternatively, we could use '.existingPlaneUsingExtent' for more grounded hit-test-points.
        
        if let closestResult = arHitTestResults.first {
            // Get Coordinates of HitTest
            
            let transform : matrix_float4x4 = closestResult.worldTransform
            let worldCoord : SCNVector3 = SCNVector3Make(baseTransform.transform.columns.3.x, baseTransform.transform.columns.3.y,baseTransform.transform.columns.3.z)
            
            let node = SCNNode()
           // node.position = worldCoord
            node.transform = SCNMatrix4(baseTransform.transform)
            node.transform.m21 = 0.0;
            node.transform.m22 = 1.0;
            node.transform.m23 = 0.0;
            print(closestResult.worldTransform)
            print(baseTransform.transform)
            print(closestResult.worldTransform - baseTransform.transform)
            let scene = SCNScene(named: "art.scnassets/ship.scn")!
            for nodeInScene in scene.rootNode.childNodes as [SCNNode] {
                node.addChildNode(nodeInScene)
            }
            sceneView.scene.rootNode.addChildNode(node)
        }
        
    
    }
    
    func updatePositionAndOrientationOf(_ node: SCNNode, withPosition position: SCNVector3, relativeTo referenceNode: SCNNode) {
        let referenceNodeTransform = matrix_float4x4(referenceNode.transform)
        
        // Setup a translation matrix with the desired position
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.x = position.x
        translationMatrix.columns.3.y = position.y
        translationMatrix.columns.3.z = position.z
        
        // Combine the configured translation matrix with the referenceNode's transform to get the desired position AND orientation
        let updatedTransform = matrix_multiply(referenceNodeTransform, translationMatrix)
        node.transform = SCNMatrix4(updatedTransform)
    }
    
    /// Create A Business Card
    func setupBusinessCard() {
        
        //1. Create Our Business Card
        let jointData = JointData(jointName: "Codo",
                                         moreInfo: ActionButtonsData(link: "http://172.20.29.210", type: .more),
            tempInfo: ActionButtonsData(link: "", type: .temp),
            speedInfo: ActionButtonsData(link: "", type: .speed))
        
        //2. Assign It To The Business Card Node
        joint = Joint(data: jointData, jointTemplate: .noProfileImage)
        
        
        //1. Create Our Business Card
        let jointBaseData = JointData(jointName: "Base",
                                  moreInfo: ActionButtonsData(link: "http://172.20.29.210", type: .more),
                                  tempInfo: ActionButtonsData(link: "", type: .temp),
                                  speedInfo: ActionButtonsData(link: "", type: .speed))
        
        //2. Assign It To The Business Card Node
        jointBase = Joint(data: jointBaseData, jointTemplate: .noProfileImage)
       
    }
    
    
    //------------------
    //MARK: - Navigation
    //------------------
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "webViewer",
            let mapWebView =  segue.destination as? MapWebViewController{
            
            mapWebView.webAddress = joint.jointData.moreInfo.link
        }
    }
    @IBAction func refreshAction(_ sender: Any) {
        nodeHolder!.removeFromParentNode()
    }
    
}
