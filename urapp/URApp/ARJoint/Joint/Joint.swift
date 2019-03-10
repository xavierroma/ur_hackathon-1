//
//  ViewController.swift
//  test
//
//  Created by XavierRoma on 08/03/2019.
//  Copyright © 2019 Salle URL. All rights reserved.
//

import Foundation
import ARKit
import WebKit
import MapKit

class Joint: SCNNode{
    
    /// Template For The Business Card
    enum JointTemplate: CustomStringConvertible{
       
        case noProfileImage
        case standard
        
        var description: String{
            switch self {
            case .noProfileImage:
                return "art.scnassets/JointTemplate.scn"
            case .standard:
                return "art.scnassets/BusinessCardTemplateB.scn"
            }
        }
    }
    
    var nameTimer: Timer?
    var time = 0
    
    let Flipped_Rotation = SCNVector4Make(0, 1, 0, GLKMathDegreesToRadians(180))
    var interactiveButtons = [SCNNode]()
    
    var jointData: JointData!
    var jointTemplate: JointTemplate!
    var businessCardTarget: SCNNode!
    var cardHolderImage: SCNNode!       { didSet { cardHolderImage.name = "imageDetected" } }
    var jointName: SCNText!
    var speedButton: SCNNode!   { didSet { speedButton.name = "speed" } }
    var tempButton: SCNNode!          { didSet { tempButton.name = "temp" } }
    var moreButton: SCNNode!         { didSet { moreButton.name = "more"} }
    
    //---------------------
    //MARK: - Intialization
    //---------------------
    
    /// Creates The Business Card
    ///
    /// - Parameters:
    ///   - data: BusinessCardData
    ///   - cardType: CardTemplate
    init(data: JointData, jointTemplate: JointTemplate) {
        
        super.init()
        
        //1. Set The Data For The Card
        self.jointData = data
        self.jointTemplate = jointTemplate
        
        //2. Extrapolate All The Nodes & Geometries
        guard let template = SCNScene(named: jointTemplate.description),
            let jointRoot = template.rootNode.childNode(withName: "RootNode", recursively: false),
            let jointName = jointRoot.childNode(withName: "jointName", recursively: false)?.geometry as? SCNText,
            let target = jointRoot.childNode(withName: "imageDetected", recursively: false),
            let speedButton = jointRoot.childNode(withName: "speed", recursively: false),
            let tempButton = jointRoot.childNode(withName: "temp", recursively: false),
            let moreButton = jointRoot.childNode(withName: "more", recursively: false)
            
        else { fatalError("Error Getting Joint Node Data") }
        
        //3. If We Are Using The Standard Template We Will Also Show The User Profile Pic
        if jointTemplate == .standard{
            let jointName = jointRoot.childNode(withName: "jointName", recursively: false)?.geometry as? SCNText
        }
        
        //4. Assign These To The BusinessCard Node
        self.businessCardTarget = target
        self.jointName = jointName
        self.jointName.flatness = 0
        self.speedButton = speedButton
        self.tempButton = tempButton
        self.moreButton = moreButton
        
        //5. Add It To The Hieracy
        self.addChildNode(jointRoot)
        self.eulerAngles.x = -.pi / 2
        
        //5. Store All The Interactive Elements
        interactiveButtons.append(speedButton)
        interactiveButtons.append(tempButton)
        interactiveButtons.append(moreButton)
        
        //6. Setup The Elements
        setBaseConfiguration()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("Business Card Coder Not Implemented") }
    
    deinit { flushFromMemory() }
    
    //---------------------------
    //MARK: - Card Elements Setup
    //---------------------------
    
    /// Sets Up The Base Configuration Of The Business Card & Makes All Elements Invisible To The User
    func setBaseConfiguration(){
        
        //1. Inavalidate The Timer
        nameTimer?.invalidate()
        time = 0
        
        businessCardTarget.isHidden = true
        
        //2. Clear The Name Data
        self.jointName.string = ""
        
        //2. Assign The Profile Image & Rotate It So It Is Hidden
        if jointTemplate == .standard{
            cardHolderImage.geometry?.firstMaterial?.diffuse.contents = UIImage(named: jointData.jointName)
            cardHolderImage.rotation = Flipped_Rotation
        }
        
        //4. Rotate All Our Interactive Buttons So We Cant See Them
        interactiveButtons.forEach{ $0.rotation = Flipped_Rotation }

    }
    
    //------------------------------
    //MARK: - Card Element Animation
    //------------------------------
    
    /// Aniumates All The Elements Of The Business Card & Makes Them Visible To The User
    func animateBusinessCard(){
        
        let rotationAsRadian = CGFloat(GLKMathDegreesToRadians(180))
        let flipAction = SCNAction.rotate(by: rotationAsRadian, around: SCNVector3(0, 1, 0), duration: 1.5)
       
        switch jointTemplate! {
    
        case .noProfileImage:
            animateBaseElementsWithAction(flipAction)
        case .standard:
            cardHolderImage.runAction(flipAction) { self.animateBaseElementsWithAction(flipAction) }
        }
        
    }

    /// Animates All Elements Except The User Profile Image
    ///
    /// - Parameter flipAction: SCNAction
    func animateBaseElementsWithAction(_ flipAction: SCNAction){
        
            //Animate the name
            self.animateTextGeometry(self.jointName, forName: self.jointData.jointName, completed: {
                
                //3. Animate All The Buttons
                self.interactiveButtons.forEach{ $0.runAction(flipAction)}
                
            })
    }
    
    /// Animates The Presentation Of SCNText
    ///
    /// - Parameters:
    ///   - textGeometry: SCNText
    ///   - name: String
    ///   - completed: () -> Void
    func animateTextGeometry(_ textGeometry: SCNText, forName name: String, completed: @escaping () -> Void ){
        
        //1. Get The Characters From The Name
        let characters = Array(name)
        
        //2. Run The Name Animation
        nameTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] timer in
            
            //a. If The Current Time Doesnt Equal The Count Of Our Characters Then Continue To Animate Our Text
            if self?.time != characters.count {
                let currentText: String = textGeometry.string as! String
                textGeometry.string = currentText + String(characters[(self?.time)!])
                self?.time += 1
            }else{
                //b. Invalide The Timer, Reset The Variables & Escape
                timer.invalidate()
                self?.time = 0
                completed()
            }
        }
    }
    
    //---------------
    //MARK: - Cleanup
    //---------------

    /// Removes All SCNMaterials & Geometries From An SCNNode
    func flushFromMemory(){
        
        print("Cleaning Business Card")
        
        if let parentNodes = self.parent?.childNodes{ parentNodes.forEach {
            $0.geometry?.materials.forEach({ (material) in material.diffuse.contents = nil })
            $0.geometry = nil
            $0.removeFromParentNode()
            }
        }
        
        for node in self.childNodes{
            node.geometry?.materials.forEach({ (material) in material.diffuse.contents = nil })
            node.geometry = nil
            node.removeFromParentNode()
        }
    }
}
