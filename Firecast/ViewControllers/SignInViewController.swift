//
//  SignInViewController.swift
//  Firecast
//
//  Created by Lakshmi Narayanan N on 29/10/18.
//  Copyright © 2018 Lakshmi Narayanan N. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    // MARK:- IB outlet
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK:- Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK:- IB actions

    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signInButtonAction(_ sender: Any) {
        userNameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        validateSignin()
    }
    
    func validateSignin() {
        guard let userName = userNameTextField.text,  userName.isEmpty != true else {
            return
        }
        
        guard let password = passwordTextField.text,  password.isEmpty != true else {
            return
        }
        
        AccountManager.shared.signIn(email: userName, password: password) { [weak self] (result, error) in
            if let _ = error {
                self?.showLogInError()
                return
            }
            
            self?.navigationController?.dismiss(animated: true, completion: {
                if let navigationController = self?.navigationController?.presentingViewController as? UINavigationController, navigationController.viewControllers[0] is LogInViewController {
                    let logInViewController = navigationController.viewControllers[0] as! LogInViewController
                    logInViewController.showHomePage()
                }
            })
        }
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}

extension SignInViewController {
    func showLogInError() {
        let alert = UIAlertController(title: "Error", message: "Can not logoin, Please try again", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

