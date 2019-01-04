//
//  PhoneLoginViewController.swift
//  Firecast
//
//  Created by Lakshmi Narayanan N on 21/08/18.
//  Copyright © 2018 Lakshmi Narayanan N. All rights reserved.
//

import UIKit

class PhoneLoginViewController: UIViewController {

    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var verificationCodeTextField: UITextField!
    
    var presenterViewController: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        phoneNumberTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func sendButtonAction(_ sender: Any) {
        guard let phoneNumber = phoneNumberTextField.text, phoneNumber.count > 0 else {
            showLogInError()
            return
        }

        AccountManager.shared.verify(phoneNumber: phoneNumber, from: self) { [unowned self] (result) in
            if result == false {
                self.showLogInError()
            }
        }
    }
    
    @IBAction func verifyButtonAction(_ sender: Any) {
        guard let verificationCode = verificationCodeTextField.text, verificationCode.count > 0 else {
            showLogInError()
            return
        }
        
        AccountManager.shared.verify(verificationCode: verificationCode) { [unowned self] (result) in
            if result == true {
                self.phoneNumberTextField.resignFirstResponder()
                self.verificationCodeTextField.resignFirstResponder()
                
                print("Phone no successfully verified")
                
                self.dismiss(animated: true, completion: {
                    if let loginViewController = self.presenterViewController as? LogInViewController {
                        loginViewController.showHomePage()
                    }
                })
            } else {
                self.showLogInError()
            }
        }
    }
    
}

extension PhoneLoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}

extension PhoneLoginViewController {
    func showLogInError() {
        let alert = UIAlertController(title: "Error", message: "Can not logoin, Please try again", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
