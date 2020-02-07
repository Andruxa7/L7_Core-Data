//
//  LoginViewController.swift
//  SwiftBeginner-L2
//
//  Created by Andrey Stecenko on 7/23/19.
//  Copyright © 2019 Andrii Stetsenko. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate {
    func didLoggedIn(identifier: String?, success: Bool)
}

class LoginViewController: UIViewController {

    var delegate: LoginViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func twitterLoginTapped(_ sender: Any) {
        let twitterLogger = TwitterLogger()
        twitterLogger.login { (identifier, error) in
            self.proccesLoginResult(identifier: identifier, error: error)
        }
    }

    @IBAction func facebookLoginTapped(_ sender: Any) {
        let facebookLogger = FacebookLogger()
        facebookLogger.login { (identifier, error) in
            self.proccesLoginResult(identifier: identifier, error: error)
        }
    }

    func proccesLoginResult(identifier: String?, error: Error?) {
        let success: Bool
        if let error = error {
            print("can't logg in to account \(error.localizedDescription)")
            success = false
        } else {
            print("account ID = \(String(describing: identifier))")
            success = true
        }

        // 1й способ (с помощью делегирования)
        self.delegate?.didLoggedIn(identifier: identifier, success: success)

        // 2й способ (с помощью обсервера)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserLoggedIn"), object: nil, userInfo: ["idn" : identifier as Any, "success" : success])

        dismiss(animated: true, completion: nil)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
