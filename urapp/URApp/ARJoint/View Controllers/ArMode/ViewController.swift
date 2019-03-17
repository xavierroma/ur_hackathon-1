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
import LocalAuthentication

class ViewController: UIViewController {
 
    //@IBOutlet var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    @IBOutlet var sceneView: VirtualObjectARView!
    @IBOutlet weak var addObjectButton: UIButton!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var focusSquare = FocusSquare()
    var actionButtonsData: ActionButtonsData?
    var targetAnchor: ARImageAnchor?
    var nodeHolder = SCNNode()
    var baseTransform:  ARAnchor!
    
    // Card
    var joint : Joint!
    var jointBase: Joint!
    
    /// Marks if the AR experience is available for restart.
    var isRestartAvailable = true
    
    lazy var statusViewController: StatusViewController = {
        return children.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()
    
    let updateQueue = DispatchQueue(label: "com.example.apple-samplecode.arkitexample.serialSceneKitQueue")
    var screenCenter: CGPoint {
        let bounds = sceneView.bounds
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //----------------------
    //MARK: - View LifeCycle
    //----------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.authenticateUser()
        
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
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "webViewer",
            let mapWebView =  segue.destination as? MapWebViewController{
            mapWebView.webAddress = joint.jointData.moreInfo.link
        }
    }
    
    func authenticateUser() {
        // Get the local authentication context.
        let context = LAContext()
        
        // Declare a NSError variable.
        var error: NSError?
        
        // Set the reason string that will appear on the authentication alert.
        let reasonString = "Authentication is needed to access your notes."
        
        // Check if the device can evaluate the policy.
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            [context .evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success: Bool, evalPolicyError: Error?) -> Void in
                if success {
                    
                    self.setupCamera()
                    self.statusViewController.restartExperienceHandler = { [unowned self] in
                        self.restartExperience()
                    }
                    self.statusViewController.scheduleMessage("FIND A SURFACE TO PLACE AN OBJECT", inSeconds: 7.5, messageType: .planeEstimation)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        self.setupARSession()
                        self.sceneView.scene.rootNode.addChildNode(self.focusSquare)
                    }
                    //setupBusinessCard()
                }
                else{
                    
                    switch evalPolicyError!._code {
                        
                    case LAError.systemCancel.rawValue:
                        self.displayErrorMessage(title: "Error",message: "Authentication was cancelled by the user")
                        
                    case LAError.userCancel.rawValue:
                        self.displayErrorMessage(title: "Error",message: "Authentication was cancelled by the user")
                        
                    default:
                        print("Authentication failed")
                    }
                }
                
            })]
        }
        else{
            
            if (LAError.biometryNotEnrolled.rawValue == 1) {
                print("TouchID not available")
            }
        }
    }
    
}
