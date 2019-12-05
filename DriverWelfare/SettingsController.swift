//
//  SettingsController.swift
//  DriverWelfare
//
//  Created by Anderson Calixto on 02/11/19.
//  Copyright © 2019 Anderson Calixto. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

class SettingsController : UIViewController {
    @IBOutlet var loggedUserLabel: UILabel?
    @IBOutlet var button: UIButton?
    
    @IBOutlet var tfCasaEndereco: UITextField?
    @IBOutlet var tfCasaLatitude: UITextField?
    @IBOutlet var tfCasaLongitude: UITextField?
    
    @IBOutlet var tfTrabalhoEndereco: UITextField?
    @IBOutlet var tfTrabalhoLatitude: UITextField?
    @IBOutlet var tfTrabalhoLongitude: UITextField?
    // almoco
    @IBOutlet var sliderHoraAlmoco:UISlider?
    @IBOutlet var valorHoraAlmoco: UILabel?
    @IBOutlet var stepperMargemAlmoco:UIStepper?
    @IBOutlet var valorMargemAlmoco: UILabel?
    // dormir
    @IBOutlet var sliderHoraDormir:UISlider?
    @IBOutlet var valorHoraDormir: UILabel?
    @IBOutlet var stepperMargemDormir:UIStepper?
    @IBOutlet var valorMargemDormir: UILabel?
    
    var localizacaoCasa:[String:Any]?
    var localizacaoTrabalho:[String:Any]?
    let geocoder = CLGeocoder()
    
    // valores padrao
    var horaAlmoco:[String:Int]?
    var horaDormir:[String:Int]?
    var margemAlmoco:Int?
    var margemDormir:Int?
    
    override func viewDidLoad() {
        
        // eventos de modificacao
        tfCasaEndereco?.addTarget(self, action: #selector(updateCasaEndereco), for: .editingDidEnd)
        tfTrabalhoEndereco?.addTarget(self, action: #selector(updateTrabalhoEndereco), for: .editingDidEnd)
        sliderHoraAlmoco?.addTarget(self, action: #selector(updateHoraAlmoco), for: .valueChanged)
        sliderHoraDormir?.addTarget(self, action: #selector(updateHoraDormir), for: .valueChanged)
        stepperMargemAlmoco?.addTarget(self, action: #selector(updateMargemAlmoco), for: .valueChanged)
        stepperMargemDormir?.addTarget(self, action: #selector(updateMargemDormir), for: .valueChanged)
        
        stepperMargemAlmoco!.stepValue = 10
        stepperMargemDormir!.stepValue = 10
        
        // dados do usuario
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        do {
            let result = try managedContext.fetch(fetchRequest)
            // se existir usuario salvo, esta logado
            if (result.count > 0) {
                let loggedUser = result[0] as! User
                let nome = loggedUser.name
                //let vc = SettingsController()
                self.loggedUserLabel?.text = nome
            }
        } catch {
            print("failed")
        }
        
        // Lendo dados salvos
        localizacaoTrabalho = UserDefaults.standard.dictionary(forKey: "localizacaoTrabalho")
        localizacaoCasa = UserDefaults.standard.dictionary(forKey: "localizacaoCasa")
        if (localizacaoCasa != nil) {
            tfCasaEndereco?.text = localizacaoCasa?["desc"] as? String
            tfCasaLatitude?.text = "\(localizacaoCasa!["latitude"] ?? "")"
            tfCasaLongitude?.text = "\(localizacaoCasa!["longitude"] ?? "")"
        }
        if (localizacaoTrabalho != nil) {
            tfTrabalhoEndereco?.text = localizacaoTrabalho?["desc"] as? String
            tfTrabalhoLatitude?.text = "\(localizacaoTrabalho!["latitude"] ?? "")"
            tfTrabalhoLongitude?.text = "\(localizacaoTrabalho!["longitude"] ?? "")"
        }
        horaAlmoco = UserDefaults.standard.dictionary(forKey: "horaAlmoco") as? [String: Int]? ?? ["hora": 12, "minuto": 0]
        horaDormir = UserDefaults.standard.dictionary(forKey: "horaDormir") as? [String: Int]? ?? ["hora": 22, "minuto": 0]
        margemAlmoco = UserDefaults.standard.object(forKey: "margemAlmoco") as? Int ?? 30
        margemDormir = UserDefaults.standard.object(forKey: "margemDormir") as? Int ?? 30

        stepperMargemAlmoco!.value = Double(margemAlmoco!)
        stepperMargemDormir!.value = Double(margemDormir!)
        sliderHoraAlmoco!.value = TimeUtil.getTimePerc(hour: horaAlmoco!["hora"]!, minute: horaAlmoco!["minuto"]!)
        sliderHoraDormir!.value = TimeUtil.getTimePerc(hour: horaDormir!["hora"]!, minute: horaDormir!["minuto"]!)
        refreshControls()
        
        // mostra interface
        super.viewDidLoad()
        
        // para sumir teclado depois que clicar fora
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func saveConfig(_ sender: UIButton) {
        print("SALVANDO CONFIGURACAO")
        if (localizacaoCasa != nil) {
            UserDefaults.standard.set(localizacaoCasa, forKey: "localizacaoCasa")
        }
        if (localizacaoTrabalho != nil) {
            UserDefaults.standard.set(localizacaoTrabalho, forKey: "localizacaoTrabalho")
        }
        UserDefaults.standard.set(horaAlmoco, forKey: "horaAlmoco")
        UserDefaults.standard.set(horaDormir, forKey: "horaDormir")
        UserDefaults.standard.set(margemAlmoco, forKey: "margemAlmoco")
        UserDefaults.standard.set(margemDormir, forKey: "margemDormir")
    }
    
    func refreshControls() {
        updateHoraAlmoco()
        updateHoraDormir()
        updateMargemAlmoco()
        updateMargemDormir()
    }
    
    @objc func updateCasaEndereco() {
        print("ENDERECO CASA ALTERADO!")
        var place: CLLocationCoordinate2D!
        // Get location of origin first
        geocoder.geocodeAddressString(tfCasaEndereco!.text!) { placemarks, error in
            guard error == nil else {
                print("Error geocoding the origin: \(String(describing: error?.localizedDescription))")
                return
            }
            guard let placemarks = placemarks, let location = placemarks.first?.location else { return }
            place = location.coordinate
            print(place!)
            self.localizacaoCasa = ["desc": self.tfCasaEndereco!.text!, "latitude": Double(place.latitude), "longitude": Double(place.longitude)]
            self.tfCasaLatitude!.text = "\(place.latitude)"
            self.tfCasaLongitude!.text = "\(place.longitude)"
        }
    }
    
    @objc func updateTrabalhoEndereco() {
        print("ENDERECO TRABALHO ALTERADO!")
        var place: CLLocationCoordinate2D!
        // Get location of origin first
        geocoder.geocodeAddressString(tfTrabalhoEndereco!.text!) { placemarks, error in
            guard error == nil else {
                print("Error geocoding the origin: \(String(describing: error?.localizedDescription))")
                return
            }
            guard let placemarks = placemarks, let location = placemarks.first?.location else { return }
            place = location.coordinate
            print(place!)
            self.localizacaoTrabalho = ["desc": self.tfTrabalhoEndereco!.text!, "latitude": Double(place.latitude), "longitude": Double(place.longitude)]
            self.tfTrabalhoLatitude!.text = "\(place.latitude)"
            self.tfTrabalhoLongitude!.text = "\(place.longitude)"
        }
    }
    
    @objc func updateHoraAlmoco() {
        valorHoraAlmoco?.text = "\(TimeUtil.getFormatHour(sliderHoraAlmoco!.value))"
        horaAlmoco = ["hora": TimeUtil.getHour(sliderHoraAlmoco!.value), "minuto": TimeUtil.getMin(sliderHoraAlmoco!.value)]
    }
    
    @objc func updateHoraDormir() {
        valorHoraDormir?.text = "\(TimeUtil.getFormatHour(sliderHoraDormir!.value))"
        horaDormir = ["hora": TimeUtil.getHour(sliderHoraDormir!.value), "minuto": TimeUtil.getMin(sliderHoraDormir!.value)]
    }
    
    @objc func updateMargemAlmoco() {
        valorMargemAlmoco?.text = "\(Int(stepperMargemAlmoco!.value)) min"
        margemAlmoco = Int(stepperMargemAlmoco!.value)
    }
    
    @objc func updateMargemDormir() {
        valorMargemDormir?.text = "\(Int(stepperMargemDormir!.value)) min"
        margemDormir = Int(stepperMargemDormir!.value)
    }
    
    @IBAction func doLogout(_ sender: UIButton) {
        // logout (remover dados de autenticacao)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                managedContext.delete(data)
            }
            do {
                try managedContext.save()
                
                // redir para tela de login
                let vc:UIViewController? = self.storyboard?.instantiateViewController(withIdentifier: "loginform")
                vc?.modalPresentationStyle = .fullScreen
                self.show(vc!, sender: self)
            } catch {
                print(error)
            }
        } catch {
            print("failed")
        }
    }
    
}

extension SettingsController {
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
