//
//  LoginController.swift
//  medview
//
//  Created by Anderson Calixto on 19/07/19.
//  Copyright © 2019 Anderson Calixto. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwdTextField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    //@IBOutlet weak var switchTouchID: UISwitch!
    //@IBOutlet weak var labelSwitchTouchID: UILabel!
    let URLBASE:String = "https://www.shellcode.com.br/driverwelfare/api"
    let URLPOST:String = "/login"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        errorMessage.text = ""
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        usernameTextField.delegate = self
        passwdTextField.delegate = self
        
        //let localAuthenticationContext = LAContext()
        //var authError: NSError?
        //if !localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
        //    labelSwitchTouchID.isHidden = true
        //    switchTouchID.isHidden = true
        //}
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func touchLoginButton(_ sender: Any) {
        if (usernameTextField.text != "" && passwdTextField.text != "") {
            autenticar()
        }
    }

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
                for (k, v) in responseJSON {
                    print("\"\(k)\":")
                    print("\(v)\n")
                    if (k == "token" && v as? String == "") {
                        DispatchQueue.main.async {
                            self.errorMessage.text = "Wrong user or password"
                        }
                    } else if (k == "token" && v as? String != "") {
                        DispatchQueue.main.async {
                            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                            let vc:UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "mainview")
                            self.present(vc, animated: true, completion: nil)
                        }
                    }
                }
                print("\n")
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
}
