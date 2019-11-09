//
//  LoginController.swift
//  medview
//
//  Created by Anderson Calixto on 19/07/19.
//  Copyright © 2019 Anderson Calixto. All rights reserved.
//

import UIKit
import LocalAuthentication
import CoreData
import LocalAuthentication

class LoginController: UIViewController, UITextFieldDelegate {
    
    /*
    // Keychain Configuration
    struct KeychainConfiguration {
      static let serviceName = "DriverWelfare"
      static let accessGroup: String? = nil
    }
    var passwordItems: [KeychainPasswordItem] = []
    */
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwdTextField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    var constraintBottom:NSLayoutConstraint?
    //@IBOutlet weak var switchTouchID: UISwitch!
    //@IBOutlet weak var labelSwitchTouchID: UILabel!
    let URLBASE:String = "https://www.shellcode.com.br/driverwelfare/api"
    let URLPOST:String = "/login"
    
    @IBOutlet var fullWidthConstraint: NSLayoutConstraint!
    var halfWidthConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {

        errorMessage.text = ""
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        usernameTextField.delegate = self
        passwdTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name:UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasHide), name:UIResponder.keyboardWillHideNotification, object: nil);

        //let localAuthenticationContext = LAContext()
        //var authError: NSError?
        //if !localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
        //    labelSwitchTouchID.isHidden = true
        //    switchTouchID.isHidden = true
        //}
        /*
        if (checkLogado()) {
            DispatchQueue.main.async {
                let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let vc:UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "mainview")
                self.present(vc, animated: true, completion: nil)
            }
        } else {

            
        }
 */
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            //fullWidthConstraint.multiplier = 16.0/1.0
            //NSLayoutConstraint.activate([halfWidthConstraint])
            //NSLayoutConstraint.deactivate([fullWidthConstraint])
        } else {
            print("Portrait")
            //NSLayoutConstraint.activate([fullWidthConstraint])
            //NSLayoutConstraint.deactivate([halfWidthConstraint])
        }
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.01
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
        print("keyboard shown")
        
        //
        if (constraintBottom == nil) {
            let info = notification.userInfo!
            
            let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

            constraintBottom = NSLayoutConstraint(
                item: self.view!,
                attribute: NSLayoutConstraint.Attribute.bottom,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: errorMessage,
                attribute: NSLayoutConstraint.Attribute.bottom,
                multiplier: 1,
                constant: keyboardFrame.size.height)

            self.view.addConstraint(constraintBottom!)
        }
        
        //self.view.addConstraint()
        /*
        self.animateViewMoving(up: true, moveValue: keyboardFrame.size.height)
 */
        //self.view.frame.origin.y = (keyboardFrame.size.height - self.view.safeAreaInsets.bottom) * -1
        
        //UIView.animateWithDuration(0.1, animations: { () -> Void in
            //self.view.bottomConstraint.constant = keyboardFrame.size.height + 20
        //})
        /* UIView.animate(withDuration: 0.01, animations: { () -> Void in
            self.view.frame.origin.y = (keyboardFrame.size.height - self.view.safeAreaInsets.bottom) * -1
        })
         */
    }

    @objc func keyboardWasHide(notification: NSNotification) {
        if (constraintBottom != nil) {
            self.view.removeConstraint(constraintBottom!)
            constraintBottom = nil
        }
        /*
        UIView.animate(withDuration: 0.01, animations: { () -> Void in
            //self.view.frame.origin.y = 0
//            let info = notification.userInfo!
//            let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//            self.animateViewMoving(up: false, moveValue: keyboardFrame.size.height)
        })
        
        */
    }

    // sumir teclado qdo clicar fora
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func touchLoginButton(_ sender: Any) {
        if (usernameTextField.text != "" && passwdTextField.text != "") {
            autenticar()
        }
    }

    // delegate ui text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //textField.resignFirstResponder()
        if textField == usernameTextField {
            print("RETURN USERNAME!!!")
            passwdTextField.becomeFirstResponder()
        } else if textField == passwdTextField {
            print("RETURN PASSWD!!!")
            if (textField.text != "") {
                autenticar()
            }
        }
        return true
    }

    /*
    func createData() {
        print("createData()")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: "User", in: managedContext)!
        let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
        user.setValue("anderson.calixto", forKey: "username")
        user.setValue("123", forKey: "token")
        user.setValue("Anderson Calixto", forKey: "name")
        do {
            try managedContext.save()
            print("Saved")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        // leitura check
        print("leitura data")
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                print("DATA: ")
                print(data.value(forKey: "username") as! String)
                print(data.value(forKey: "token") as! String)
                print(data.value(forKey: "name") as! String)
                //managedContext.delete(data)
            }
//            do {
//                try managedContext.save()
//            } catch {
//                print(error)
//            }
        } catch {
            print("failed")
        }
    }
 */
    
}

extension CGRect {
    init(_ x:CGFloat, _ y:CGFloat, _ w:CGFloat, _ h:CGFloat) {
        self.init(x:x, y:y, width:w, height:h)
    }
}

extension LoginController {
    
    func autenticar() {
        print("INITIALIZING AUTH!!!")
        DispatchQueue.main.async {
            let user:String = self.usernameTextField.text ?? ""
            let pass:String = self.passwdTextField.text ?? ""
            if self.submit(user: user, pass: pass) {
                print("OK!")
            }
        }
    }
    
    func attemptPost(user: String, pass: String, _ completion:@escaping (String)->()) {
        completion("teste")
    }
    
    func submit(user: String, pass: String) -> Bool {
        let json: [String: Any] = [
            "username": user,
            "password": pass
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: "\(self.URLBASE)\(self.URLPOST)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            guard let res = (response as? HTTPURLResponse), (200...299).contains(res.statusCode) else {
                DispatchQueue.main.async {
                    self.errorMessage.text = "Falhou... tente mais tarde..."
                }
                return
            }
            print("RAW DATA: ")
            print(String(data: data, encoding: String.Encoding.utf8) ?? "")
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print("JSON DATA: ")
                var token:String?
                var name:String?
                for (k, v) in responseJSON {
                    print("\"\(k)\":")
                    print("\(v)\n")
                    if (k == "token" && v as? String != "") {
                        token = v as? String
                    } else if (k == "name" && v as? String != "") {
                        name = v as? String
                    }
                }
                print("\n")
                if (token != nil) {
                    // SALVAR
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                    let managedContext = appDelegate.persistentContainer.viewContext
                    let userObj = NSEntityDescription.insertNewObject(forEntityName: "User", into: managedContext) as! User
                    userObj.name = name
                    userObj.token = token
                    userObj.username = user
                    do {
                        try managedContext.save()
                    } catch {
                        print(error)
                    }
                    self.readAll()
                    
                    DispatchQueue.main.async {
                        //let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        //let vc:UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "mainview")
                        //self.present(vc, animated: true, completion: nil)
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainview")
                        vc?.modalPresentationStyle = .fullScreen
                        self.present(vc!, animated: true, completion: nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage.text = "Wrong user or password"
                    }
                }
            }
        }
        task.resume()
        return true
    }
    func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
        var message = ""
        if #available(iOS 11.0, macOS 10.13, *) {
            switch errorCode {
            case LAError.biometryNotAvailable.rawValue:
                message = "Authentication could not start because the device does not support biometric authentication."
            case LAError.biometryLockout.rawValue:
                message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
            case LAError.biometryNotEnrolled.rawValue:
                message = "Authentication could not start because the user has not enrolled in biometric authentication."
            default:
                message = "Did not find error code on LAError object"
            }
        } else {
            switch errorCode {
            case LAError.touchIDLockout.rawValue:
                message = "Too many failed attempts."
            case LAError.touchIDNotAvailable.rawValue:
                message = "TouchID is not available on the device"
            case LAError.touchIDNotEnrolled.rawValue:
                message = "TouchID is not enrolled on the device"
            default:
                message = "Did not find error code on LAError object"
            }
        }
        return message;
    }
    
    func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
        var message = ""
        switch errorCode {
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
        case LAError.notInteractive.rawValue:
            message = "Not interactive"
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
        case LAError.userCancel.rawValue:
            message = "The user did cancel"
        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"
        default:
            message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
        }
        return message
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
    
    func readAll() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // leitura check
        print("leitura data")
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                print("DATA: ")
                print(data.value(forKey: "username") as! String)
                print(data.value(forKey: "token") as! String)
                print(data.value(forKey: "name") as! String)
                //managedContext.delete(data)
            }
//            do {
//                try managedContext.save()
//            } catch {
//                print(error)
//            }
        } catch {
            print("failed")
        }
    }
}
