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

class SettingsController : UIViewController {
    @IBOutlet var loggedUserLabel: UILabel?
    @IBOutlet var button: UIButton?
    @IBOutlet var tfCasaLatitude: DecimalMinusTextField?
    @IBOutlet var tfCasaLongitude: DecimalMinusTextField?
    @IBOutlet var tfTrabalhoLatitude: DecimalMinusTextField?
    @IBOutlet var tfTrabalhoLongitude: DecimalMinusTextField?

    override func viewDidLoad() {
 
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
        
        let fetchRequestAddrCasa = NSFetchRequest<NSFetchRequestResult>(entityName: "Address")
        let filter = "CASA"
        let predicate = NSPredicate(format: "type = %@", filter)
        fetchRequest.predicate = predicate
        do {
            let result = try managedContext.fetch(fetchRequestAddrCasa)
            // se existir usuario salvo, esta logado
            if (result.count > 0) {
                let addr = result[0] as! Address
                tfCasaLatitude?.text = String(addr.latitude)
                tfCasaLongitude?.text = String(addr.longitude)
            } else {
                // posicao casa padrao
                tfCasaLatitude?.text = String(Lugares.casa.coordinate.latitude)
                tfCasaLongitude?.text = String(Lugares.casa.coordinate.longitude)
                
                // salvar
                let newLocal = NSEntityDescription.insertNewObject(forEntityName: "Address", into: managedContext) as! Address
                newLocal.type = filter
                newLocal.latitude = Lugares.casa.coordinate.latitude
                newLocal.longitude = Lugares.casa.coordinate.longitude
                do {
                    try managedContext.save()
                } catch {
                    print(error)
                }
            }
        } catch {
            print("failed")
        }
        
        // trabalho
        let fetchRequestAddrTrabalho = NSFetchRequest<NSFetchRequestResult>(entityName: "Address")
        let filterTrabalho = "TRABALHO"
        let predicateTrabalho = NSPredicate(format: "type = %@", filterTrabalho)
        fetchRequestAddrTrabalho.predicate = predicateTrabalho
        do {
            let result = try managedContext.fetch(fetchRequestAddrTrabalho)
            // se existir usuario salvo, esta logado
            if (result.count > 0) {
                let addr = result[0] as! Address
                tfTrabalhoLatitude?.text = String(addr.latitude)
                tfTrabalhoLongitude?.text = String(addr.longitude)
            } else {
                // posicao trabalho padrao
                tfTrabalhoLatitude?.text = String(Lugares.walterCantidio.coordinate.latitude)
                tfTrabalhoLongitude?.text = String(Lugares.walterCantidio.coordinate.longitude)
                
                // salvar
                let newLocal = NSEntityDescription.insertNewObject(forEntityName: "Address", into: managedContext) as! Address
                newLocal.type = filterTrabalho
                newLocal.latitude = Lugares.walterCantidio.coordinate.latitude
                newLocal.longitude = Lugares.walterCantidio.coordinate.longitude
                do {
                    try managedContext.save()
                } catch {
                    print(error)
                }
            }
        } catch {
            print("failed")
        }

        super.viewDidLoad()

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
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
