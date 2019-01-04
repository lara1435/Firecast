//
//  HomeViewController.swift
//  Firecast
//
//  Created by Lakshmi Narayanan N on 17/08/18.
//  Copyright © 2018 Lakshmi Narayanan N. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import GoogleSignIn

class HomeViewController: UIViewController {
    
    // MARK:- Properties
    
    var currentUser: User? {
        return AccountManager.shared.currentUser
    }
    
    let marvelManager = MarvelManager()
    let marvelCharacters: [String : String] = [:]
    
    // MARK:- IB outlet
    
    @IBOutlet weak var greetingLabel: UILabel!
    
    // MARK:- Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let displayName = currentUser?.displayName {
            greetingLabel.text = "Hi, \(displayName),"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadMarvelCharacters()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - IB actions
    
    @IBAction func addButtonAction(_ sender: Any) {
        let socialLoginAlert = UIAlertController(title: "", message: "Select the social network you want to add with the current account", preferredStyle: .actionSheet)
        let googleAction = UIAlertAction(title: "Google", style: .default) { [weak self] _ in
            self?.addGoogleAccountWithCurrentUser()
        }
        socialLoginAlert.addAction(googleAction)
        
        let facebookAction = UIAlertAction(title: "Facebook", style: .default) { [weak self] _ in
            self?.addFacebookAccountWithCurrentUser()
        }
        socialLoginAlert.addAction(facebookAction)
        
        let twitterAction = UIAlertAction(title: "Twitter", style: .default) { [weak self] _ in
            self?.addTwitterAccountWithCurrentUser()
        }
        socialLoginAlert.addAction(twitterAction)
        
        let phoneAction = UIAlertAction(title: "Phone Number", style: .default) { [weak self] _ in
            self?.addPhoneNumberWithCurrentUser()
        }
        socialLoginAlert.addAction(phoneAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        socialLoginAlert.addAction(cancelAction)
        
        self.present(socialLoginAlert, animated: true, completion: nil)
    }
    
    @IBAction func tapButtonAction(_ sender: Any) {
        AccountManager.shared.getLinkedAccounts()
//        guard let user = currentUser else {
//            showUnAuthorisedUserError()
//            return
//        }
//
//        if user.isAnonymous == true {
//            showUnAuthorisedUserError()
//            return
//        }
//
//        // Valid user
//        testLog()
    }
    
    @IBAction func signOutBarButtonAction(_ sender: Any) {
        AccountManager.shared.signOut { [unowned self] (result) in
            if result == true {
                self.showLoginPage()
            } else {
                self.showLogOutError()
            }
        }
    }
}

extension HomeViewController {
    func addGoogleAccountWithCurrentUser() {
        AccountManager.shared.linkWithGoogle { [unowned self] (result, error) in
            if error != nil {
                self.showLoginMergeError()
            }
            
            if result == true {
                self.showLoginMergeSuccess()
            } else {
                self.showLoginMergeError()
            }
        }
    }
    
    func addFacebookAccountWithCurrentUser() {
        AccountManager.shared.linkWithFacebookFrom(viewController: self) { [unowned self] (result, error) in
            if error != nil {
                self.showLoginMergeError()
            }
            
            if result == true {
                self.showLoginMergeSuccess()
            } else {
                self.showLoginMergeError()
            }
        }
    }
    
    func addTwitterAccountWithCurrentUser() {
        AccountManager.shared.linkWithTwitter { [unowned self] (result, error) in
            if error != nil {
                self.showLoginMergeError()
            }
            
            if result == true {
                self.showLoginMergeSuccess()
            } else {
                self.showLoginMergeError()
            }
        }
    }
    
    func addPhoneNumberWithCurrentUser() {
        
    }
}

extension HomeViewController {
    func testLog() {
        let ref = Database.database().reference()
        ref.child("logs").child((currentUser?.uid)!).setValue("\(arc4random())") { [unowned self] (error, ref) in
            if let _ = error {
                self.showWriteError()
            }
        }
    }
    
    func showUnAuthorisedUserError() {
        let alert = UIAlertController(title: "Error", message: "you are not logged in", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showWriteError() {
        let alert = UIAlertController(title: "Error", message: "Can not write to firebase, Please try again later", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension HomeViewController {
    func showLoginPage() {
        if let _ = self.navigationController?.presentingViewController {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let navigationController = mainStoryBoard.instantiateViewController(withIdentifier: "LoginNavigationController") as! UINavigationController
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    func showLogOutError() {
        let alert = UIAlertController(title: "Error", message: "Can not logout, Please try again", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension HomeViewController {
    func showLoginMergeSuccess() {
        let alert = UIAlertController(title: "Success", message: "Successfully merged with current user", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showLoginMergeError() {
        let alert = UIAlertController(title: "Error", message: "Can not login, Please try again", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func loadMarvelCharacters() {
        marvelManager.getMarvelCharacters { (characters) in
            print("characters: \(characters)")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell Identifier", for: indexPath)
        cell.textLabel?.text = "Hello"
        return cell
    }
}

extension HomeViewController: GIDSignInUIDelegate {}
