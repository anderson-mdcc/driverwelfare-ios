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

class RecommendationsController : UIViewController, CLLocationManagerDelegate {
    var placesClient: GMSPlacesClient!
    var turno = Turno.MANHA

    // Add a pair of UILabels in Interface Builder, and connect the outlets to these variables.
    @IBOutlet var infoTextView:UITextView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    var locationManager: CLLocationManager?
    var speechSynthesizer = AVSpeechSynthesizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        infoTextView.text = ""

        //let hour = Calendar.current.component(.hour, from: Date())
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateClock), userInfo: nil, repeats: true)

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        placesClient = GMSPlacesClient.shared()
    }
    
    //Update clock every second
    @objc func updateClock() {
        //let now = NSDate()
        //print(now)
        var bom = "Boa"
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
        let strTurno:String = turno.description.lowercased()
        
        infoTextView.text = "\(bom) \(strTurno), Fulano!\nAguarde por minhas recomendações e tenha uma boa viagem!"
    }

    // Add a UIButton in Interface Builder, and connect the action to this function.
    @IBAction func getCurrentPlace(_ sender: UIButton) {

        // falar
      let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: "Buscando localização atual")
      speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.0
      speechUtterance.voice = AVSpeechSynthesisVoice(language: "pt-BR")
      self.speechSynthesizer.speak(speechUtterance)

      placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
        if let error = error {
          print("Current Place error: \(error.localizedDescription)")
          return
        }

        self.nameLabel.text = "No current place"
        self.addressLabel.text = ""

        if let placeLikelihoodList = placeLikelihoodList {
          let place = placeLikelihoodList.likelihoods.first?.place
          if let place = place {
            self.nameLabel.text = place.name
            self.addressLabel.text = place.formattedAddress?.components(separatedBy: ", ")
              .joined(separator: "\n")
            let localizacao = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            let distanceDouble = Lugares.casa.distance(from: localizacao)
            print(distanceDouble)
            let distance: Int = Int(distanceDouble / 1000)
            var strFala = "Boa noite Anderson, você está em casa!"
            if (distanceDouble > 500) {
                strFala = "Boa noite Anderson, você está em \(place.name!), \(distance) quilômetros de casa!"
            }
            // falar
            let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: strFala)
            speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.0
            speechUtterance.voice = AVSpeechSynthesisVoice(language: "pt-BR")
            self.speechSynthesizer.speak(speechUtterance)

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
}
