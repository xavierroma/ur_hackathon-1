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
import Jelly

class ViewController: UIViewController {
 
    
    /// Marks if the AR experience is available for restart.
    var isRestartAvailable = true
    var focusSquare = FocusSquare()
    var settings = Settings()
    //@IBOutlet var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    @IBOutlet weak var shooterProgramButton: UIButton!
    @IBOutlet weak var undoProgramButton: UIButton!
    @IBOutlet weak var crossHair: UIButton!
    var programProgrammingMode = [SCNNode]()
    var programPoints = [SCNNode]()
    
    @IBOutlet var sceneView: VirtualObjectARView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var settingsButton: UIButton!
    
    var actionButtonsData: ActionButtonsData?
    var nodeHolder: SCNNode!
    
    var chartNode: ARBarChart!
    var startingRotation: Float = 0.0
    
    var selectedNode: SCNNode!
    var sceneWalls: [SCNNode] = []
    var currentTrackingPosition: CGPoint!
    var robotMonitor: RobotMonitoring!
    // Card
    var joint : Joint!
    var jointBase: Joint!
    
    var animator: Jelly.Animator?
    var settingsAnimator: Jelly.Animator?
    let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
    var viewControllerToPresent: UIViewController!
    var settingsViewController: SettingsViewController!
    
    enum BodyType : Int {
        case ObjectModel = 2;
    }
    
    
    
    lazy var statusViewController: StatusViewController = {
        return children.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()
    
    let updateQueue = DispatchQueue(label: "serialSceneKitQueue")
    var screenCenter: CGPoint {
        let bounds = UIScreen.main.bounds
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
        MIDINotification()
        //self.authenticateUser()
        setUpSettingsView()
        setUpChatView()
        setUpJointInfo()
        self.setupARSession()
        robotMonitor = RobotMonitoring(settings.robotIP, Int32(settings.robotPort))
        
    }
    
    func setUpSettingsView () {
        settingsViewController = (self.storyboard!.instantiateViewController(withIdentifier: "settingsIdentifier") as! SettingsViewController)
        //settingsViewController.settings = self.settings;
        let interactionConfiguration = InteractionConfiguration(presentingViewController: self, completionThreshold: 0.5, dragMode: .edge)
        //let uiConfiguration = PresentationUIConfiguration(backgroundStyle: .dimmed(alpha: 0.5))
        let uiConfiguration = PresentationUIConfiguration(cornerRadius: 10, backgroundStyle: .dimmed(alpha: 0.5))
        let size = PresentationSize(width: .custom(value: CGFloat(500)), height: .fullscreen)
        let marginGuards = UIEdgeInsets(top: 50, left: 16, bottom: 50, right: 16)
        let alignment = PresentationAlignment(vertical: .center, horizontal: .left)
        let presentation = CoverPresentation(directionShow: .left, directionDismiss: .left, uiConfiguration: uiConfiguration, size: size, alignment: alignment, marginGuards: marginGuards, interactionConfiguration: interactionConfiguration)
        //let presentation = SlidePresentation(uiConfiguration: uiConfiguration, direction: .right, size: .halfscreen, interactionConfiguration: interactionConfiguration)
        let animator = Animator(presentation: presentation)
        animator.prepare(presentedViewController: settingsViewController)
        self.settingsAnimator = animator
        
    }
    
    func setUpChatView () {
        viewControllerToPresent = self.storyboard!.instantiateViewController(withIdentifier: "PresentMe")
        let interactionConfiguration = InteractionConfiguration(presentingViewController: self, completionThreshold: 0.5, dragMode: .edge)
        //let uiConfiguration = PresentationUIConfiguration(backgroundStyle: .dimmed(alpha: 0.5))
        let uiConfiguration = PresentationUIConfiguration(cornerRadius: 10, backgroundStyle: .dimmed(alpha: 0.5))
        let size = PresentationSize(width: .halfscreen, height: .halfscreen)
        let marginGuards = UIEdgeInsets(top: 50, left: 16, bottom: 50, right: 16)
        let alignment = PresentationAlignment(vertical: .center, horizontal: .right)
        let presentation = CoverPresentation(directionShow: .right, directionDismiss: .right, uiConfiguration: uiConfiguration, size: size, alignment: alignment, marginGuards: marginGuards, interactionConfiguration: interactionConfiguration)
        //let presentation = SlidePresentation(uiConfiguration: uiConfiguration, direction: .right, size: .halfscreen, interactionConfiguration: interactionConfiguration)
        let animator = Animator(presentation: presentation)
        animator.prepare(presentedViewController: viewControllerToPresent)
        self.animator = animator

    }
    @IBAction func displaySettingsView(_ sender: Any) {
        settingsViewController.settings = self.settings
        present(settingsViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func displayChatView(_ sender: Any) {
        
        present(viewControllerToPresent, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        actionButtonsData = nil
        self.navigationController?.isNavigationBarHidden = true
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        robotMonitor.close()
        // Pause the view's session
        //sceneView.session.pause()
    }
    
    func showGraphs() {
        
        guard (nodeHolder != nil) else {return}
        
        chartNode = ChartCreator.createBarChart(at: SCNVector3(x: -0.5, y: 0, z: -0.5), seriesLabels: Array(0..<2).map({ "Series \($0)" }), indexLabels: Array(0..<2).map({ "Index \($0)" }), values: [[1.3,2.1],[5.1,4.22]])
        
        nodeHolder.addChildNode(chartNode);
    }
    
    func displayJoinInfo(jointNumber: JointIdentifier, matrix: SCNMatrix4) {
        
        guard (nodeHolder != nil) else {return}
        let position: SCNVector3
        //Get info from desired joint
        switch jointNumber {
        case .base:
            print("Base")
            position = SCNVector3(-0.5,1,0.1);
        case .elbow:
            print("elbow")
        case .shoulder:
            print("shoulder")
            position = SCNVector3(-0.5,1,0.1);
        case .tool:
            print("tool")
            position = SCNVector3(-0.5,1,0.1);
        }
        
        //Display on desired joint position
        
        joint.transform = matrix
        joint.transform.m21 = 0.0
        joint.transform.m22 = 1.0
        joint.transform.m23 = 0.0
        print("Posant joint info")
        sceneView.scene.rootNode.addChildNode(joint);
        
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
    
    func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        
        let indices: [Int32] = [0, 1]
        
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        return SCNGeometry(sources: [source], elements: [element])
        
    }
    
    @IBAction func undoProgramPoint(_ sender: Any) {
        
        print("Undo zero - \(programProgrammingMode.count)")
        if programProgrammingMode.count > 0 {
            print("Undo one - \(programProgrammingMode.count)")
            var node = programProgrammingMode.removeLast()
            node.removeFromParentNode()
            print("Undo one - \(programProgrammingMode.count)")
            if programProgrammingMode.count > 0 {
                print("Undo two - \(programProgrammingMode.count)")
                node = programProgrammingMode.removeLast()
                print("Undo two - \(programProgrammingMode.count)")
                node.removeFromParentNode()
            }
        }
    }
    
    @IBAction func addProgramPoint(_ sender: Any) {
        
        guard let result = sceneView.hitTest(CGPoint(x: screenCenter.x, y: screenCenter.y), types: [.existingPlaneUsingExtent, .featurePoint]).first else { return }
        
            let sphere = SCNSphere(radius: 0.005)
            let node = SCNNode(geometry: sphere)
        
            node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
            node.position = SCNVector3(x: result.worldTransform.columns.3.x, y: result.worldTransform.columns.3.y, z: result.worldTransform.columns.3.z)
        
        
        
            sceneView.scene.rootNode.addChildNode(node)
        
            if programProgrammingMode.count >= 1 {
                let line = lineFrom(vector: (programProgrammingMode.last?.position)!, toVector: node.position)
                let lineNode = SCNNode(geometry: line)
                lineNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
                sceneView.scene.rootNode.addChildNode(lineNode)
                
                programProgrammingMode.append(lineNode)
            }
            //It is important to do this append AFTER the line node is appended
            programProgrammingMode.append(node)
        
    }
    
    /// Create A Joint Card
    func setUpJointInfo() {
        
        //1. Create Our Business Card
        let jointData = JointData(jointName: "Codo",
                                         moreInfo: ActionButtonsData(link: "http://172.20.29.210", type: .more),
            tempInfo: ActionButtonsData(link: "", type: .temp),
            speedInfo: ActionButtonsData(link: "", type: .speed))
        
        //2. Assign It To The Joint Node
        joint = Joint(data: jointData, jointTemplate: .noProfileImage)
        
        
        //1. Create Our Business Card
        let jointBaseData = JointData(jointName: "Base",
                                  moreInfo: ActionButtonsData(link: "http://172.20.29.210", type: .more),
                                  tempInfo: ActionButtonsData(link: "", type: .temp),
                                  speedInfo: ActionButtonsData(link: "", type: .speed))
        
        //2. Assign It To The Joint Node
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
        let reasonString = "Authentication is needed to verify your identity."
        
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
