//
//  ViewController.swift
//  test
//
//  Created by XavierRoma on 08/03/2019.
//  Copyright © 2019 Salle URL. All rights reserved.
//

import Foundation

typealias ActionButtonsData = (link: String, type: ActionButtons)

/// The Information For The Business Card Node & Contact Details
struct JointData{
    
    var jointName: String
    var moreInfo: ActionButtonsData
    var tempInfo: ActionButtonsData
    var speedInfo: ActionButtonsData
    
}

enum ActionButtons: String{
    
    case more
    case speed
    case temp
}
