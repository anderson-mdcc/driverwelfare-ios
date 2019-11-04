//
//  ViewController.swift
//  DriverWelfare
//
//  Created by Anderson Calixto on 15/10/19.
//  Copyright © 2019 Anderson Calixto. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    var timer:Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
         timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(swaptologin),
            userInfo: nil,
            repeats: false)
        //let loginControler = self.storyboard?.instantiateViewController(withIdentifier: "loginform") as! LoginController
        //print(loginControler.nibName!)
        //self.navigationController?.pushViewController(loginControler, animated: true)
    }
    
    @objc func swaptologin() {
        var vc:UIViewController?
        if (checkLogado()) {
            vc = self.storyboard?.instantiateViewController(withIdentifier: "mainview")
        } else {
            vc = self.storyboard?.instantiateViewController(withIdentifier: "loginform")
        }
        vc?.modalPresentationStyle = .fullScreen
        self.show(vc!, sender: self)
    }

    @objc func fire() {
        print("Instanciar LoginController")
        let loginControler = self.storyboard?.instantiateViewController(withIdentifier: "loginform") as! LoginController
        self.navigationController?.pushViewController(loginControler, animated: true)
        /* let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var vc:UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "loginform")
        if (checkLogado()) {
            vc = mainStoryboard.instantiateViewController(withIdentifier: "mainview")
        }
        self.present(vc, animated: true, completion: nil)
 */
    }

    func checkLogado() -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        do {
            let result = try managedContext.fetch(fetchRequest)
            // se existir usuario salvo, esta logado
            return result.count > 0
        } catch {
            print("failed")
        }
        return false
    }

}

