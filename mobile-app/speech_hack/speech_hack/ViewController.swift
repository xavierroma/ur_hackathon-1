//
//  ViewController.swift
//  speech_hack
//
//  Created by Guillem Garrofé Montoliu on 27/11/2018.
//  Copyright © 2018 Guillem Garrofé Montoliu. All rights reserved.
//

import UIKit
import Speech
import ApiAI
import AVFoundation

struct ChatMessage {
    let text: String
    let isIncoming: Bool
}


class ViewController:  UIViewController, UITableViewDataSource, UITableViewDelegate,SFSpeechRecognizerDelegate{
    
    @IBOutlet weak var labelVeu: UILabel!
    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var labelResponse: UILabel!
    var textInput: String!;

    @IBOutlet var tableView: UITableView!
    let speechStynthesizer = AVSpeechSynthesizer()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    //variable tutorial
    fileprivate let cellId = "id"
    
    var chatMessages = [
        ChatMessage(text: "Here's my very first message", isIncoming: false),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "UR Chatbot"
        
        navigationController?.navigationBar.prefersLargeTitles = true;
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: cellId);
        
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1);
        tableView.separatorStyle = .none;
        
        // Do any additional setup after loading the view, typically from a nib.
        microphoneButton.isEnabled = false  //2
        
         speechRecognizer?.delegate = self  //3
        
         SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
         
             var isButtonEnabled = false
            
             switch authStatus {  //5
                 case .authorized:
                    isButtonEnabled = true
                
                 case .denied:
                     isButtonEnabled = false
                     print("User denied access to speech recognition")
                
                 case .restricted:
                     isButtonEnabled = false
                     print("Speech recognition restricted on this device")
                
                 case .notDetermined:
                     isButtonEnabled = false
                     print("Speech recognition not yet authorized")
             }
            
             OperationQueue.main.addOperation() {
             self.microphoneButton.isEnabled = isButtonEnabled
             }
         }
    }
    
    //Retonamos el numero de celas que tiene la tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count;
    }
    
    //Contenido de cada row de la
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatMessageCell;
        
        let chatMessage = chatMessages[indexPath.row];
        cell.chatMessage = chatMessage;
        return cell;
    }
    

    func speechAndText(text: String) {
        let speechUtterance = AVSpeechUtterance(string: text)
        speechStynthesizer.speak(speechUtterance)
        //if para cuando esta vacio
        let chatMessage = ChatMessage(text: text, isIncoming: true);
        self.chatMessages.append(chatMessage);
        self.tableView.reloadData();
        let ip = NSIndexPath(row: self.chatMessages.count-1, section: 0)
        self.tableView.scrollToRow(at: ip as IndexPath, at: .bottom, animated: false)
    }
    
    func sendMessage() {
        let request = ApiAI.shared().textRequest()
        
        if let text = self.textInput, text != "" {
            request?.query = text
        } else {
            return
        }
        
        request?.setMappedCompletionBlockSuccess({ (request, response) in
            let response = response as! AIResponse
            
            
            //print(aux["Mode"])
            //print("Debug \(aux.next().unsafelyUnwrapped)");
            /*for (key,value) in aux{
                print("Para la key \(key), tenemos \(value)")
            }*/
            if let textResponse = response.result.fulfillment.speech {
                self.speechAndText(text: textResponse)
            }
            self.responseBehaviour(response)
        }, failure: { (request, error) in
            print(error!)
        })
        
        ApiAI.shared().enqueue(request)
    }
    
    func responseBehaviour(_ response: AIResponse) {
        var aux = response.result.parameters as! Dictionary<String, Any>
        let mode = aux["Mode"] as? AIResponseParameter;
        if(mode != nil){
            print("Debug \(mode!.stringValue ?? "bon dia")")
        }
    }
    
    @IBAction func microphoneClick(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            microphoneButton.isEnabled = false
            microphoneButton.setTitle("Start Recording", for: .normal)
            sendMessage()
        } else {
            startRecording()
            microphoneButton.setTitle("Stop Recording", for: .normal)
            
        }
    }
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record, mode: .default, options: [])
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode;
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            if result != nil {
                
                self.textInput = (result?.bestTranscription.formattedString)!
                isFinal = (result?.isFinal)!
            }
            
            if (error != nil || isFinal) {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                if(self.textInput != nil){
                    self.chatMessages.append(ChatMessage(text: self.textInput, isIncoming: false))
                    /*self.tableView.reloadData()
                    let ip = NSIndexPath(row: self.chatMessages.count-1, section: 0)
                    self.tableView.scrollToRow(at: ip as IndexPath, at: .bottom, animated: false)*/
                }
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.microphoneButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        //labelResponse.text = "Say something, I'm listening!"
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }
    
}


