//
//  ViewController.swift
//  DriverWelfare
//
//  Created by Anderson Calixto on 15/10/19.
//  Copyright © 2019 Anderson Calixto. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var timer:Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(fire),
            userInfo: nil,
            repeats: false)
    }

    @objc func fire() {
        let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc:UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "loginform")
        self.present(vc, animated: true, completion: nil)
    }

}

