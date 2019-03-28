//
//  SettingViewController.swift
//  URApp
//
//  Created by XavierRoma on 17/03/2019.
//  Copyright © 2019 x.roma_gabriel.cammany. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var robotIP: UITextField!
    @IBOutlet weak var robotPort: UITextField!
    @IBOutlet weak var webURL: UITextField!
    @IBOutlet weak var qrCode: UITextField!
    @IBOutlet weak var programingMode: UISwitch!
    @IBOutlet weak var robotWalls: UISwitch!
    @IBOutlet weak var robotWallsOpacity: UISlider!
    @IBOutlet weak var robotWallsOpacityLabel: UILabel!
    @IBOutlet weak var robotControls: UISwitch!
    @IBOutlet weak var viewProgram: UISwitch!
    
    var settings: Settings!
    
    override func viewDidLoad() {
        
        self.navigationController?.isNavigationBarHidden = false
        //self.keyboardDismissMode = UIScrollView.KeyboardDismissMode.onDrag;
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
            
        settings.robotIP = robotIP.text!
        settings.robotPort = Int(robotPort.text!) ?? settings.robotPort
        settings.webAddress = webURL.text!
        settings.syncQrCode = Int(qrCode.text!) ?? settings.syncQrCode
        
        NotificationCenter.default.post(name: .updateSettings, object: settings)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        speedSlider.value = Float(settings.robotSpeed)
        speedLabel.text = "\(settings.robotSpeed)"
        robotIP.text = settings.robotIP
        robotPort.text = "\(settings.robotPort)"
        webURL.text = settings.webAddress
        qrCode.text = "\(settings.syncQrCode)"
        programingMode.isOn = settings.programingMode
        robotWalls.isOn = settings.robotWalls
        robotWallsOpacity.value = Float(settings.robotWallsOpacity)
        robotWallsOpacityLabel.text = "\(settings.robotWallsOpacity)"
        robotControls.isOn = settings.virtualControls
        viewProgram.isOn = settings.visualizeProgram
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func viewLimitsAction(_ sender: Any) {
        settings.robotWalls = robotWalls.isOn
        NotificationCenter.default.post(name: .showWalls, object: settings)
    }
    
    @IBAction func modeProgramingAction(_ sender: Any) {
        settings.programingMode = programingMode.isOn
        NotificationCenter.default.post(name: .showProgramMode, object: settings)
    }
    
    @IBAction func showRobotControlsAction(_ sender: Any) {
        settings.virtualControls = robotControls.isOn
        //NotificationCenter.default.post(name: , object: settings)
    }
    
    @IBAction func wallsOpacitySlideAction(_ sender: Any) {
        settings.robotWallsOpacity = round(Double(robotWallsOpacity.value))
        robotWallsOpacityLabel.text = "\(settings.robotWallsOpacity)"
        NotificationCenter.default.post(name: .updateOpacity, object: settings)
    }
    
    @IBAction func showCurrentProgramAction(_ sender: Any) {
        settings.visualizeProgram = viewProgram.isOn
        NotificationCenter.default.post(name: .showCurrentProgram, object: settings)
    }
    
    @IBAction func speedSlideAction(_ sender: Any) {
        settings.robotSpeed = round(Double(speedSlider.value))
        speedLabel.text = "\(settings.robotSpeed)"
    }
    
}
