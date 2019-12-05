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
import Foundation


class RecommendationsController : UIViewController, CLLocationManagerDelegate {
    var label: UILabel!
    var fromMicButton: UIButton!
    
    var labelQuestion: UILabel!
    var labelQuestion2: UILabel!
    var labelHelp: UILabel!
    var labelHelpConclusion: UILabel!
    var labelRecomendations: UILabel!
    
    var buttonYes: UIButton!
    var buttonNot: UIButton!
    
    var sub: String!
    var region: String!
    // Old
    var placesClient: GMSPlacesClient!
    var turno = Turno.MANHA
    var bom = "Boa"
    var nome:String!
    var latitude: String!
    var longitude: String!
    var localizacao: CLLocation!
    
    var action: String = ""
    var itsFarFromHome: Bool = true
    var recommendationsList: [String] = []
    var recommendationsDistanceList: [String] = []
    
    var recommendationsHotelsList: [String] = []
    var recommendationsHotelsDistanceList: [String] = []
    
    var lunchTimeIsUsed: Int = 0
    var sleepTimeIsUsed: Int = 0

    // Add a pair of UILabels in Interface Builder, and connect the outlets to these variables.
    //@IBOutlet var infoTextView:UITextView!
    //@IBOutlet var nameLabel: UILabel!
    //@IBOutlet var addressLabel: UILabel!
    var locationManager: CLLocationManager?
    var speechSynthesizer = AVSpeechSynthesizer()
    var textRecommendations : String!

    override func viewDidLoad() {
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

                updateClock()
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
                
                labelQuestion2 = UILabel(frame: CGRect(x: 50, y: 70, width: 300, height: 200))
                labelQuestion2.textColor = UIColor.black
                labelQuestion2.lineBreakMode = .byWordWrapping
                labelQuestion2.numberOfLines = 0
                
                labelHelp = UILabel(frame: CGRect(x: 50, y: 120, width: 300, height: 200))
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
                
                labelRecomendations = UILabel(frame: CGRect(x: 50, y: 350, width: 300, height: 350))
                labelRecomendations.textColor = UIColor.black
                labelRecomendations.lineBreakMode = .byWordWrapping
                labelRecomendations.numberOfLines = 0
                
                fromMicButton = UIButton(frame: CGRect(x: 50, y: 700, width: 300, height: 50))
                fromMicButton.setTitle("Responder", for: .normal)
                fromMicButton.addTarget(self, action:#selector(self.fromMicButtonClicked), for: .touchUpInside)
                let iconMicrofone = UIImage(named: "microfone")!
                fromMicButton.setImage(iconMicrofone, for: .normal)
                fromMicButton.backgroundColor = UIColor(red:0.16, green:0.65, blue:0.27, alpha:1.0)
                fromMicButton.isHidden = true
                
                self.routineLocation()
                Timer.scheduledTimer(withTimeInterval: 25, repeats: true) { timer in
                    let hour = Calendar.current.component(.hour, from: Date())
                    let minute = Calendar.current.component(.minute, from: Date())
                    //print("Time: \(hour):\(minute)")
                    self.checkLunchTime(hour: hour, minute: minute)
                }
                Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { timer in
                    let hour = Calendar.current.component(.hour, from: Date())
                    let minute = Calendar.current.component(.minute, from: Date())
                    //print("Time: \(hour):\(minute)")
                    self.checkSleepTime(hour: hour, minute: minute)
                }
                Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { timer in
                    self.checkCurrentPlace()
                }
                
                self.view.addSubview(labelQuestion)
                self.view.addSubview(labelQuestion2)
                self.view.addSubview(labelHelp)
                self.view.addSubview(label)
                self.view.addSubview(buttonYes)
                self.view.addSubview(buttonNot)
                self.view.addSubview(labelHelpConclusion)
                self.view.addSubview(labelRecomendations)
                self.view.addSubview(fromMicButton)
            }
        } catch {
            print("failed")
        }
    }
    
    func searchRestaurants(){
        print("searchRestaurants")
        let lat: String!
        let lon: String!
        lat = self.latitude ?? ""
        lon = self.longitude ?? ""
        let url = URL(string: "https://places.cit.api.here.com/places/v1/autosuggest?at=\(lat ?? ""),\(lon ?? "");r=5000&q=restaurant&app_id=e5fdpl98RXqdZPLpPmWq&app_code=m3JQwpzpmA50XYQHQ7fWbQ")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        self.recommendationsList = []
        self.recommendationsDistanceList = []
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            guard let res = (response as? HTTPURLResponse), (200...299).contains(res.statusCode) else {
                DispatchQueue.main.async {
                    print("Falhou... tente mais tarde...")
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                //print("JSON DATA: ")
                if var array = responseJSON["results"] as? [Any]{
                    if let firstObject = array.first {
                        // access individual object in array
                        //array.remove(at: 0)
                    }
                    var count: Int = 0
                    for object in array {
                        let currentConditions = object as! [String:Any]
                        if(count > 0){
                            if let text = currentConditions["title"] {
                                self.recommendationsList += ["\(text)"]
                            } else {
                               self.recommendationsList += [""]
                            }
                            
                            if let text = currentConditions["distance"] {
                                var distanceInt = text as! Int
                                if(distanceInt > 1000){
                                    distanceInt = Int(distanceInt/1000)
                                    let distanceString: String = String(distanceInt)
                                    self.recommendationsDistanceList += ["\(distanceString) km"]
                                }else{
                                    self.recommendationsDistanceList += ["\(text) metros"]
                                }
                                
                            } else {
                               self.recommendationsDistanceList += [""]
                            }
                        }
                        if(count == 5){
                            break
                        }
                        
                        count += 1
                    }

                }
            }
            print(self.recommendationsList)
            print(self.recommendationsDistanceList)
            self.openRestaurants()
            print("\n")
            print("\n")
        }
        task.resume()
    }
    func searchHotels(){
        print("search Hotels")
        let lat: String!
        let lon: String!
        lat = self.latitude ?? ""
        lon = self.longitude ?? ""
        let url = URL(string: "https://places.cit.api.here.com/places/v1/autosuggest?at=\(lat ?? ""),\(lon ?? "")&q=accommodation&app_id=e5fdpl98RXqdZPLpPmWq&app_code=m3JQwpzpmA50XYQHQ7fWbQ")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        self.recommendationsHotelsList = []
        self.recommendationsHotelsDistanceList = []
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            guard let res = (response as? HTTPURLResponse), (200...299).contains(res.statusCode) else {
                DispatchQueue.main.async {
                    print("Failed ... try later ...")
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                if let array = responseJSON["results"] as? [Any]{
                    var count: Int = 0
                    for object in array {
                        let currentConditions = object as! [String:Any]
                        if(count > 0){
                            if let text = currentConditions["title"] {
                                self.recommendationsHotelsList += ["\(text)"]
                            } else {
                               self.recommendationsHotelsList += [""]
                            }
                            
                            if let text = currentConditions["distance"] {
                                var distanceInt = text as! Int
                                if(distanceInt > 1000){
                                    distanceInt = Int(distanceInt/1000)
                                    let distanceString: String = String(distanceInt)
                                    self.recommendationsHotelsDistanceList += ["\(distanceString) km"]
                                }else{
                                    self.recommendationsHotelsDistanceList += ["\(text) metros"]
                                }
                                
                            } else {
                               self.recommendationsHotelsDistanceList += [""]
                            }
                        }
                        if(count == 5){
                            break
                        }
                        count += 1
                    }

                }
            }
            print(self.recommendationsHotelsList)
            print(self.recommendationsHotelsDistanceList)
            self.openHotels()
        }
        task.resume()
    }
    
    func routineLocation(){
        getCurrentPlace()
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            self.routineStart()
        }
    }
    
    func routineStart(){
        self.action = "starting"
        var textRecommendations:String!
        textRecommendations = "Posso te ajudar em algo?"
        self.labelQuestion2.text = textRecommendations
        self.speak(text:textRecommendations)
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            self.fromMicButton.isHidden = false
            self.fromMicButton.sendActions(for: .touchUpInside)
        }
        
        labelHelp.text = "responda RESTAURANTE ou HOTEL"
        label.text = "........"
    }
    
    func routineLunch(_ attemps: Int){
        print("Tentativa \(attemps)")
        let attemp: Int = attemps
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if(self.action != "" && self.itsFarFromHome == false){
                self.routineLunch(attemp - 1)
            }else{
                self.action = "lunch"
                var textRecommendations:String!
                textRecommendations = "Vejo que ainda não almoçou, gostaria de uma recomendação de restaurante?"
                self.labelQuestion2.text = textRecommendations
                self.speak(text:textRecommendations)
                DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                    self.fromMicButton.isHidden = false
                    self.fromMicButton.sendActions(for: .touchUpInside)
                }
                
                self.labelHelp.text = "responda SIM ou NÃO"
                self.label.text = "........"
                self.labelHelpConclusion.text = ""
            }
        }
    }
    
    func routineSleep(_ attemps: Int){
        print("Tentativa Sleep \(attemps)")
        let attemp: Int = attemps
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if(self.action != "" && self.itsFarFromHome == false){
                self.routineSleep(attemp - 1)
            }else{
                self.action = "sleep"
                var textRecommendations:String!
                textRecommendations = "Gostaria de uma recomendação de hotel?"
                self.labelQuestion2.text = textRecommendations
                self.speak(text:textRecommendations)
                DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                    self.fromMicButton.isHidden = false
                    self.fromMicButton.sendActions(for: .touchUpInside)
                }
                
                self.labelHelp.text = "responda SIM ou NÃO"
                self.label.text = "........"
                self.labelHelpConclusion.text = ""
            }
        }
    }
    
    func routineHydration(){
        
    }
    
    func checkLunchTime(hour: Int, minute: Int){
        var lunchTime = self.getLunchTime()
        var lunchTimeHour: Int = lunchTime["hora"] ?? 0
        var lunchTimeMinute: Int = lunchTime["minuto"] ?? 0
        var lunchTimeMargin: Int = self.getLunchTimeMargin()
        
        var lunchTimeHourWithMargin:Int = lunchTimeHour
        var lunchTimeMinuteWithMargin:Int = lunchTimeMinute
        if(lunchTimeMargin > 60){
            lunchTimeHourWithMargin += lunchTimeMargin/60
            let r = Double(lunchTimeMargin).remainder(dividingBy: 60.0)
            lunchTimeMinuteWithMargin += Int(r)
        }else{
            lunchTimeMinuteWithMargin += lunchTimeMargin
        }

        let calendar = Calendar.current
        let now = Date()
        let time_today = calendar.date(
            bySettingHour: lunchTimeHour, minute: lunchTimeMinute, second: 0,of: now)!
        // TODO: FIX
        //let time_today_margin = calendar.date(
        //    bySettingHour: lunchTimeHourWithMargin,minute: lunchTimeMinuteWithMargin,second: 0, of: now)!
        let time_today_margin = calendar.date(
            bySettingHour: 14, minute: 30,second: 0, of: now)!
        
        if now >= time_today && now <= time_today_margin && self.lunchTimeIsUsed == 0
        {
          print("The time is between \(time_today) and \(time_today_margin)")
          self.lunchTimeIsUsed = 1
          self.routineLunch(10)
        }else{
          print("The time is not to")
        }
        self.checkIsNow()
        
    }
    func getLunchTime() -> [String: Int]{
        return UserDefaults.standard.dictionary(forKey: "horaAlmoco") as? [String: Int] ?? ["hora": 12, "minuto": 0]
    }

    func getSleepTime() -> [String: Int]{
        return UserDefaults.standard.dictionary(forKey: "horaDormir") as? [String: Int] ?? ["hora": 22, "minuto": 0]
    }
    func getLunchTimeMargin() -> Int{
        return UserDefaults.standard.object(forKey: "margemAlmoco") as? Int ?? 30
    }
    func getSleepTimeMargin() -> Int{
        return UserDefaults.standard.object(forKey: "margemDormir") as? Int ?? 30
    }
    
    func getDistanceMargin() -> String{
        return "500"
    }
    func checkSleepTime(hour: Int, minute: Int){
        var sleepTime = self.getSleepTime()
        var sleepTimeHour: Int = sleepTime["hora"] ?? 0
        var sleepTimeMinute: Int = sleepTime["minuto"] ?? 0
        var sleepTimeMargin: Int = self.getSleepTimeMargin()
        var sleepTimeHourWithMargin:Int = sleepTimeHour ?? 0
        var sleepTimeMinuteWithMargin:Int = sleepTimeMinute ?? 0
        if(sleepTimeMargin > 60){
            sleepTimeHourWithMargin += sleepTimeMargin/60
            let r = Double(sleepTimeMargin).remainder(dividingBy: 60.0)
            sleepTimeMinuteWithMargin += Int(r)
        }else{
            sleepTimeMinuteWithMargin += sleepTimeMargin
        }

        let calendarSleep = Calendar.current
        let nowSleep = Date()
        let time_today_sleep = calendarSleep.date(bySettingHour: sleepTimeHour, minute: sleepTimeMinute, second: 0, of: nowSleep)!
        
        //let time_today_margin_sleep = calendarSleep.date(bySettingHour: sleepTimeHourWithMargin, minute: sleepTimeMinuteWithMargin, second: 0, of: nowSleep)!
        let time_today_margin_sleep = calendarSleep.date(bySettingHour: 14, minute: 0, second: 0, of: nowSleep)!
        
        if nowSleep >= time_today_sleep && nowSleep <= time_today_margin_sleep && self.sleepTimeIsUsed == 0
        {
          print("The sleep time is between \(time_today_sleep) and \(time_today_margin_sleep)")
          self.sleepTimeIsUsed = 1
          self.routineSleep(10)
        }else{
          print("The sleep time is not to")
        }
    }
    
    func checkIsNow(){
        let hour = Calendar.current.component(.hour, from: Date())
        let minute = Calendar.current.component(.hour, from: Date())
        if (hour == 3 && minute == 0) {
            self.lunchTimeIsUsed = 0
            self.sleepTimeIsUsed = 0
        }
    }
    func openRestaurants(){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            var textRecommendations:String!
            textRecommendations = "encontrei \(self.recommendationsList.count) restaurantes próximos a sua localização"
            self.speak(text: textRecommendations)
            self.labelHelpConclusion.text = textRecommendations
            
            textRecommendations = self.formatStringByListOfRecommendations()
            self.labelRecomendations.text = textRecommendations
            self.speak(text: textRecommendations)
            
            var time: Double = 7.0
            time *= Double(self.recommendationsList.count)
            DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                self.fromMicButton.isHidden = false
                self.fromMicButton.sendActions(for: .touchUpInside)
                self.labelHelpConclusion.text = ""
                self.buttonYes.isHidden = true
                self.buttonNot.isHidden = true
            }
        }
        
    }
    
    func openHotels(){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            var textRecommendations:String!
            textRecommendations = "encontrei \(self.recommendationsHotelsList.count) hoteis próximos a sua localização"
            self.labelHelpConclusion.text = textRecommendations
            self.speak(text: textRecommendations)
            
            textRecommendations = self.formatStringByListOfRecommendationsHotels()
            self.labelRecomendations.text = textRecommendations
            self.speak(text: textRecommendations)
            
            var time: Double = 7.0
            time *= Double(self.recommendationsHotelsList.count)
            DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                self.fromMicButton.isHidden = false
                self.fromMicButton.sendActions(for: .touchUpInside)
                self.labelHelpConclusion.text = ""
                self.buttonYes.isHidden = true
                self.buttonNot.isHidden = true
            }
        }
        
    }
    
    
    func formatStringByListOfRecommendations() -> String{
        var text:String!
        text = "Escolha uma opção.\n"
        for (index, value) in self.recommendationsList.enumerated() {
            print("Item \(index + 1): \(value)")
            let strAuxValue: String = String(describing: value)
            text += "Opção \(index + 1), \(strAuxValue ?? ""), a \(recommendationsDistanceList[index]).\n"
        }
        return text
    }
    
    func formatStringByListOfRecommendationsHotels() -> String{
        var text:String!
        text = "Escolha uma opção.\n"
        for (index, value) in self.recommendationsHotelsList.enumerated() {
            print("Item \(index + 1): \(value)")
            let strAuxValue: String = String(describing: value)
            text += "Opção \(index + 1), \(strAuxValue ?? ""), a \(recommendationsHotelsDistanceList[index]).\n"
        }
        return text
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

        if let placeLikelihoodList = placeLikelihoodList {
          let place = placeLikelihoodList.likelihoods.first?.place
          if let place = place {
            self.localizacao = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            self.latitude = String(place.coordinate.latitude)
            self.longitude = String(place.coordinate.longitude)
            
            var localizacaoCasa = UserDefaults.standard.dictionary(forKey: "localizacaoCasa") ?? ["desc": "","latitude": Double(0), "longitude": Double(0)]
            
            //let latStr = localizacaoCasa["latitude"] ?? ""
            //let lonStr = localizacaoCasa["longitude"] ?? ""
            //let lat: Double? = Double(latStr)
            //let lon: Double? = Double(lonStr)
            let lat: Double? = localizacaoCasa["latitude"] as? Double
            let lon: Double? = localizacaoCasa["longitude"] as? Double
            
            let casa = CLLocation(latitude: lat ?? 0, longitude: lon ?? 0)
            let distanceDouble = casa.distance(from: self.localizacao)
            print(distanceDouble)
            let distance: Int = Int(distanceDouble / 1000)
            let strTurno:String = self.turno.description.lowercased()
            print(distance)
            print(strTurno)
            let greets:String = "\(self.bom) \(strTurno) \(self.nome!)"
            var strFala = "\(greets), você está em casa!"
            self.labelQuestion.text = strFala
            if (distanceDouble > 500) {
                strFala = "\(greets), você está em \(place.name!), \(Int(distance)) quilômetros de casa!"
                self.labelQuestion.text = strFala
            }
            self.speak(text: strFala)
            

          }
        }
      })
    }
    
    func checkCurrentPlace() {

      placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
        if let error = error {
          print("Current Place error: \(error.localizedDescription)")
          return
        }
        if let placeLikelihoodList = placeLikelihoodList {
          let place = placeLikelihoodList.likelihoods.first?.place
          if let place = place {
            self.localizacao = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            self.latitude = String(place.coordinate.latitude)
            self.longitude = String(place.coordinate.longitude)
            
            var localizacaoCasa = UserDefaults.standard.dictionary(forKey: "localizacaoCasa") as? [String: String] ?? ["desc": "","latitude": "", "longitude": ""]
            
            let latStr = localizacaoCasa["latitude"] ?? ""
            let lonStr = localizacaoCasa["longitude"] ?? ""
            let lat: Double? = Double(latStr)
            let lon: Double? = Double(lonStr)
            
            let casa = CLLocation(latitude: lat ?? 0, longitude: lon ?? 0)
            let distanceDouble = casa.distance(from: self.localizacao)
            
            let distance: Int = Int(distanceDouble / 1000)
            let distanceMargin: Double = Double(self.getDistanceMargin()) ?? 500.0
            if (distanceDouble > distanceMargin) {
                self.itsFarFromHome = true
            }else{
                self.itsFarFromHome = false
            }
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
                if(self.action == "lunch"){
                    self.searchRestaurants()
                }else{
                    if(self.action == "sleep"){
                        self.openHotels()
                    }
                }
            }
            
        }else{
            if text.lowercased().range(of:"não") != nil {
                print("não")
                DispatchQueue.main.async { // Make sure you're on the main thread here
                    self.buttonYes.isHidden = false
                    self.buttonNot.isHidden = false
                }
            }else{
                if text.lowercased().range(of:"restaurante") != nil {
                    print("restaurante")
                    DispatchQueue.main.async { // Make sure you're on the main thread here
                        self.buttonYes.isHidden = false
                        self.buttonNot.isHidden = false
                        self.searchRestaurants()
                        self.action = "openRestaurants"
                    }
                }else{
                    if text.lowercased().range(of:"hotel") != nil {
                        print("hoteis")
                        DispatchQueue.main.async { // Make sure you're on the main thread here
                            self.buttonYes.isHidden = false
                            self.buttonNot.isHidden = false
                            self.searchHotels()
                            self.action = "openHotels"
                        }
                    }else{
                        for (index, value) in self.recommendationsList.enumerated() {
                            print("\(value)")
                            if text.lowercased().range(of:"opção \(index + 1)") != nil {
                                DispatchQueue.main.async { // Make sure you're on the main thread here
                                    self.buttonYes.isHidden = false
                                    self.buttonNot.isHidden = false
                                    self.labelHelpConclusion.text = "abrindo Opção \(index + 1)"
                                    // Navigate from one coordinate to another
                                    let lat: String!
                                    let lon: String!
                                    var q: String!
                                    lat = self.latitude ?? ""
                                    lon = self.longitude ?? ""
                                    
                                    if(self.action == "openRestaurants"){
                                        q = self.recommendationsList[(index + 1)]
                                    }else{
                                        q = self.recommendationsHotelsList[(index + 1)]
                                    }
                                    self.action = ""
                                    
                                    q = q.replacingOccurrences(of: " ", with: "+")
                                    
                                    let urlS = "http://maps.apple.com/?q=\(q ?? "")&sll=\(lat ?? ""),\(lon ?? "")&z=10&t=s&directionsmode=driving"
                                    print(urlS)
                                    if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!))
                                    {
                                        UIApplication.shared.openURL(NSURL(string:
                                            "comgooglemaps://?saddr=&daddr=\(lat ?? ""),\(lon ?? "")&directionsmode=driving")! as URL)
                                    } else
                                    {
                                        print("not have google maps")
                                        if let url = URL(string: urlS) {
                                            UIApplication.shared.openURL(url)
                                        }
                                    }
                                }
                                return
                            }
                        }
                        
                        DispatchQueue.main.async { // Make sure you're on the main thread here
                            self.labelHelpConclusion.text = "não entendi sua resposta :("
                            self.action = ""
                        }
                    }
                }
            }
        }
    }

}
