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
import LocalAuthentication
import ARCharts

class ViewController: UIViewController {
 
    
    /// Marks if the AR experience is available for restart.
    var isRestartAvailable = true
    var focusSquare = FocusSquare()
    var settings = Settings()
    //@IBOutlet var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    @IBOutlet var sceneView: VirtualObjectARView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    var actionButtonsData: ActionButtonsData?
    var nodeHolder: SCNNode!
    
    var chartNode: ARBarChart!
    var startingRotation: Float = 0.0
    
    var selectedNode: SCNNode!
    var sceneWalls: [SCNNode] = []
    
    var currentTrackingPosition: CGPoint!
    // Card
    var joint : Joint!
    var jointBase: Joint!
    
    enum BodyType : Int {
        case ObjectModel = 2;
    }
    
    
    
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
        
        self.setupCamera()
        self.statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(updateSettings), name: .updateSettings, object: nil)
        //self.authenticateUser()
        
        self.setupARSession()
    }
    

    @objc func updateSettings(notification: Notification) {
        if let newSettings = notification.object as! Settings? {
            self.settings = newSettings
            print("Settings")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        actionButtonsData = nil
        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        //sceneView.session.pause()
    }
    
    func updateFocusSquare(isObjectVisible: Bool) {
        if isObjectVisible {
            self.focusSquare.hide()
        } else {
            self.focusSquare.unhide()
            statusViewController.scheduleMessage("Try moving left or right", inSeconds: 5.0, messageType: .focusSquare)
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
    
   
    
    /// Create A Joint Card
    func setUpJointInfo() {
        
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
        } else if segue.identifier == "settingsSegue",
            let settingsView = segue.destination as? SettingsViewController {
                settingsView.settings = self.settings
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
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        self.setupARSession()
                    }
                    
                }
                else{
                    
                    switch evalPolicyError!._code {
                        
                    case LAError.systemCancel.rawValue:
                        print( "Authentication was cancelled by the user")
                        
                    case LAError.userCancel.rawValue:
                        print( "Authentication was cancelled by the user")
                        
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