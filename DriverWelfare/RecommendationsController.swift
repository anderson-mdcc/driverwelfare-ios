//
//  RecommendationsController.swift
//  DriverWelfare
//
//  Created by Anderson Calixto on 28/10/19.
//  Copyright © 2019 Anderson Calixto. All rights reserved.
//

import Foundation
import UIKit
import GooglePlaces
import CoreLocation
import AVFoundation
import CoreData

class RecommendationsController : UIViewController, CLLocationManagerDelegate {
    var label: UILabel!
    var fromMicButton: UIButton!
    
    var labelQuestion: UILabel!
    var labelQuestion2: UILabel!
    var labelHelp: UILabel!
    var labelHelpConclusion: UILabel!
    
    var buttonYes: UIButton!
    var buttonNot: UIButton!
    
    var sub: String!
    var region: String!
    // Old
    var placesClient: GMSPlacesClient!
    var turno = Turno.MANHA
    var bom = "Boa"
    var nome:String!

    // Add a pair of UILabels in Interface Builder, and connect the outlets to these variables.
    //@IBOutlet var infoTextView:UITextView!
    //@IBOutlet var nameLabel: UILabel!
    //@IBOutlet var addressLabel: UILabel!
    var locationManager: CLLocationManager?
    var speechSynthesizer = AVSpeechSynthesizer()
    var textRecommendations : String!

    override func viewDidLoad() {
        //infoTextView.text = ""
        //nameLabel.text = ""
        //addressLabel.text = ""
        super.viewDidLoad()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        do {
            let result = try managedContext.fetch(fetchRequest)
            // se existir usuario salvo, esta logado
            if (result.count > 0) {
                let loggedUser = result[0] as! User
                self.nome = loggedUser.name
                //let vc = SettingsController()
                //vc.loggedUserLabel.text = nome

                //let hour = Calendar.current.component(.hour, from: Date())
                Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateClock), userInfo: nil, repeats: true)

                locationManager = CLLocationManager()
                locationManager?.delegate = self
                locationManager?.requestAlwaysAuthorization()
                placesClient = GMSPlacesClient.shared()
                
                // load subscription information
                sub = "184943600bbb498a880676f74d37a04a"
                region = "westus"
                
                labelQuestion = UILabel(frame: CGRect(x: 50, y: 0, width: 300, height: 200))
                labelQuestion.textColor = UIColor.black
                labelQuestion.lineBreakMode = .byWordWrapping
                labelQuestion.numberOfLines = 0
                
                labelQuestion2 = UILabel(frame: CGRect(x: 50, y: 50, width: 300, height: 200))
                labelQuestion2.textColor = UIColor.black
                labelQuestion2.lineBreakMode = .byWordWrapping
                labelQuestion2.numberOfLines = 0
                
                labelHelp = UILabel(frame: CGRect(x: 50, y: 100, width: 300, height: 200))
                labelHelp.textColor = UIColor.blue
                labelHelp.lineBreakMode = .byWordWrapping
                labelHelp.numberOfLines = 0
                
                label = UILabel(frame: CGRect(x: 50, y: 150, width: 300, height: 200))
                label.textColor = UIColor.black
                label.lineBreakMode = .byWordWrapping
                label.numberOfLines = 0
                
                buttonYes = UIButton(frame: CGRect(x: 40, y: 200, width: 100, height: 200))
                buttonNot = UIButton(frame: CGRect(x: 120, y: 200, width: 100, height: 200))
                let iconLike = UIImage(named: "like")!
                let iconDislike = UIImage(named: "dislike")!
                buttonYes.setImage(iconLike, for: .normal)
                buttonNot.setImage(iconDislike, for: .normal)
                buttonYes.isHidden = true
                buttonNot.isHidden = true

                labelHelpConclusion = UILabel(frame: CGRect(x: 50, y: 250, width: 300, height: 200))
                labelHelpConclusion.textColor = UIColor.blue
                labelHelpConclusion.lineBreakMode = .byWordWrapping
                labelHelpConclusion.numberOfLines = 0
                labelHelpConclusion.isHidden = true
                
                fromMicButton = UIButton(frame: CGRect(x: 50, y: 400, width: 300, height: 50))
                fromMicButton.setTitle("Responder", for: .normal)
                fromMicButton.addTarget(self, action:#selector(self.fromMicButtonClicked), for: .touchUpInside)
                let iconMicrofone = UIImage(named: "microfone")!
                fromMicButton.setImage(iconMicrofone, for: .normal)
                fromMicButton.backgroundColor = UIColor(red:0.16, green:0.65, blue:0.27, alpha:1.0)
                
                
                
                routineLocation()

                self.view.addSubview(labelQuestion)
                self.view.addSubview(labelHelp)
                self.view.addSubview(label)
                self.view.addSubview(buttonYes)
                self.view.addSubview(buttonNot)
                self.view.addSubview(labelHelpConclusion)
                self.view.addSubview(fromMicButton)
            }
        } catch {
            print("failed")
        }
    }
    
    func routineLocation(){
        getCurrentPlace()
        self.labelQuestion2.text = "gostaria de uma recomendação de restaurante?"
        //routineStart()
    }
    
    func routineStart(){
        textRecommendations = "Olá \(nome ?? ""), gostaria de uma recomendação de restaurante?"
        labelQuestion.text = textRecommendations
        speak(text:textRecommendations)
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            self.fromMicButton.sendActions(for: .touchUpInside)
        }
        
        labelHelp.text = "responda SIM ou NÃO"
        label.text = "........"
        labelHelpConclusion.text = "não entendi sua resposta :("
    }
    
    func routineLunch(){
        
    }
    
    func routineDinner(){
        
    }
    
    func routineHydration(){
        
    }
    
    func speak(text: String){
        let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.0
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "pt-BR")
        self.speechSynthesizer.speak(speechUtterance)
    }
    //Update clock every second
    @objc func updateClock() {
        //let now = NSDate()
        //print(now)
        let hour = Calendar.current.component(.hour, from: Date())
        if (hour >= 0 && hour < 6) {
            turno = Turno.MADRUGADA
        } else if (hour >= 6 && hour < 12) {
            turno = Turno.MANHA
            bom = "Bom"
        } else if (hour >= 12 && hour < 18) {
            turno = Turno.TARDE
        } else {
            turno = Turno.NOITE
        }
        //let strTurno:String = turno.description.lowercased()
        
        //infoTextView.text = "\(bom) \(strTurno), \(nome!)!\nAguarde por minhas recomendações e tenha uma boa viagem!"
    }

    // Add a UIButton in Interface Builder, and connect the action to this function.
    func getCurrentPlace() {

      placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
        if let error = error {
          print("Current Place error: \(error.localizedDescription)")
          return
        }

        //self.nameLabel.text = "No current place"
        //self.addressLabel.text = ""

        if let placeLikelihoodList = placeLikelihoodList {
          let place = placeLikelihoodList.likelihoods.first?.place
          if let place = place {
            //self.nameLabel.text = place.name
            //self.addressLabel.text = place.formattedAddress?.components(separatedBy: ", ").joined(separator: "\n")
            let localizacao = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            let distanceDouble = Lugares.casa.distance(from: localizacao)
            print(distanceDouble)
            let distance: Int = Int(distanceDouble / 1000)
            let strTurno:String = self.turno.description.lowercased()
            print(distance)
            print(strTurno)
            let greets:String = "\(self.bom) \(strTurno) \(self.nome!)"
            var strFala = "\(greets), você está em casa!"
            self.labelQuestion.text = strFala
            if (distanceDouble > 500) {
                strFala = "\(greets), você está em \(place.name!), \(distance) quilômetros de casa!"
                self.labelQuestion.text = strFala
            }
            self.speak(text: strFala)

          }
        }
      })
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    // do stuff
                }
            }
        }
    }
    
    @objc func fromMicButtonClicked() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.recognizeFromMic()
        }
    }
    
    func recognizeFromMic() {
        var speechConfig: SPXSpeechConfiguration?
        do {
            try speechConfig = SPXSpeechConfiguration(subscription: sub, region: region)
        } catch {
            print("error \(error) happened")
            speechConfig = nil
        }
        speechConfig?.speechRecognitionLanguage = "pt-BR"
        
        let audioConfig = SPXAudioConfiguration()
        
        let reco = try! SPXSpeechRecognizer(speechConfiguration: speechConfig!, audioConfiguration: audioConfig)
        
        reco.addRecognizingEventHandler() {reco, evt in
            print("intermediate recognition result: \(evt.result.text ?? "(no result)")")
            self.updateLabel(text: evt.result.text, color: .gray)
        }
        
        updateLabel(text: "Ouvindo ...", color: .gray)
        print("Listening...")
        
        let result = try! reco.recognizeOnce()
        print("recognition result: \(result.text ?? "(no result)")")
        updateLabel(text: result.text, color: .black)
        checkSpeech(text: result.text ?? "(no result)")
    }
    
    func updateLabel(text: String?, color: UIColor) {
        DispatchQueue.main.async {
            self.label.text = text
            self.label.textColor = color
        }
    }
    
    func checkSpeech(text: String){
        print("checking text: \(text)")
        //labelHelpConclusion.isHidden = true
        if text.lowercased().range(of:"sim") != nil {
            print("sim")
            DispatchQueue.main.async { // Make sure you're on the main thread here
                self.buttonYes.isHidden = false
                self.buttonNot.isHidden = false
            }
            
        }else{
            if text.lowercased().range(of:"não") != nil {
                print("não")
                DispatchQueue.main.async { // Make sure you're on the main thread here
                    self.buttonYes.isHidden = false
                    self.buttonNot.isHidden = false
                }
            }else{
                DispatchQueue.main.async { // Make sure you're on the main thread here
                    self.labelHelpConclusion.isHidden = false
                }
            }
        }
    }
}
