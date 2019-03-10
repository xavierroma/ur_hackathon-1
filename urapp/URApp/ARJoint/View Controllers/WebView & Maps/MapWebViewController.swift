//
//  ViewController.swift
//  test
//
//  Created by XavierRoma on 08/03/2019.
//  Copyright © 2019 Salle URL. All rights reserved.
//

import UIKit
import MapKit
import WebKit

class MapWebViewController: UIViewController, WKUIDelegate {
    
    var isWebsite = true
    
    //---------------
    //MARK: - WebView
    //---------------
    var webView: WKWebView!
    var webAddress: String!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string:"http://192.168.1.57/login")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
}
    


