//
//  SignUpViewController.swift
//  Firecast
//
//  Created by Lakshmi Narayanan N on 29/10/18.
//  Copyright © 2018 Lakshmi Narayanan N. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    // MARK:- IB outlet
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK:- Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK:- IB actions
    
    @IBAction func signInButtonAction(_ sender: Any) {
        userNameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        createUser()
    }
    
    func createUser() {
        guard let userName = userNameTextField.text,  userName.isEmpty != true else {
            return
        }
        
        guard let password = passwordTextField.text,  password.isEmpty != true else {
            return
        }
        
        AccountManager.shared.signUp(email: userName, password: password) { [weak self] (result, error) in
            if let _ = error {
                self?.showSignUpError()
                return
            }
            
            self?.navigationController?.dismiss(animated: true, completion: {
                if let loginViewController = self?.navigationController?.presentedViewController as? LogInViewController {
                    loginViewController.showHomePage()
                }
            })
        }
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}

extension SignUpViewController {
    func showSignUpError() {
        let alert = UIAlertController(title: "Error", message: "Email has been registered already", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

