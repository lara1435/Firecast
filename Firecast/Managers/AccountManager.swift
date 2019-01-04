//
//  AccountManager.swift
//  Firecast
//
//  Created by Lakshmi Narayanan N on 17/08/18.
//  Copyright © 2018 Lakshmi Narayanan N. All rights reserved.
//

import UIKit
import Firebase

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}

enum LoginError: Error {
    case unknown
}

class AccountManager: NSObject {
    static let shared = AccountManager()
    
    var firebaseManager: FirebaseManager!
    var googleManager: GoogleManager!
    var facebookManager: FacebookManager!
    var twitterManager: TwitterManager!
    var phoneAuthManager: PhoneAuthManager!
    var emailAuthManager: EmailAuthManager!
    
    private override init() {
        let persistentManager = PersistentManager()
        firebaseManager = FirebaseManager(persistentManager: persistentManager)
        
        googleManager = GoogleManager(firebaseManager: firebaseManager)
        facebookManager = FacebookManager(firebaseManager: firebaseManager)
        twitterManager = TwitterManager(firebaseManager: firebaseManager)
        phoneAuthManager = PhoneAuthManager(firebaseManager: firebaseManager)
        emailAuthManager = EmailAuthManager(firebaseManager: firebaseManager)
    }
}

extension AccountManager {
    var currentUser: User? {
        return firebaseManager.currentUser
    }
}

extension AccountManager {
    func doAnonymousLogin(then: @escaping (Bool, Error?) -> Void) -> Void {
        firebaseManager.doAnonymousLogin { (result, error) in
            then(result, error)
        }
    }
    
    func signIn(email: String, password: String, complitionHandler: @escaping (Bool, Error?) -> Void) -> Void {
        emailAuthManager.signIn(userName: email, password: password) { (result, error) in
            if let error = error {
                complitionHandler(false, error)
                return
            }
            
            if result == true {
                complitionHandler(true, nil)
            } else {
                complitionHandler(false, LoginError.unknown)
            }
        }
    }
    
    func signUp(email: String, password: String, complitionHandler: @escaping (Bool, Error?) -> Void) -> Void {
        emailAuthManager.signUp(userName: email, password: password) { (result, error) in
            if let error = error {
                complitionHandler(false, error)
                return
            }
            
            if result == true {
                complitionHandler(true, nil)
            } else {
                complitionHandler(false, LoginError.unknown)
            }
        }
    }
    
    func loginWithGoogle(complitionHandler: @escaping (Bool, Error?) -> Void) -> Void {
        googleManager.loginWithGoogle { (result, error) in
            if let error = error {
                complitionHandler(false, error)
                return
            }
            
            if result == true {
                complitionHandler(true, nil)
            } else {
                complitionHandler(false, LoginError.unknown)
            }
        }
    }
    
    func linkWithGoogle(complitionHandler: @escaping (Bool, Error?) -> Void) -> Void {
        googleManager.linkWithGoogle { (result, error) in
            if let error = error {
                complitionHandler(false, error)
                return
            }
            
            if result == true {
                complitionHandler(true, nil)
            } else {
                complitionHandler(false, LoginError.unknown)
            }
        }
    }
    
    func loginWithFacebookFrom(viewController: UIViewController, complitionHandler: @escaping (Bool, Error?) -> ()) {
        facebookManager.loginFrom(viewController: viewController) { (result, error) in
            if let error = error {
                complitionHandler(false, error)
                return
            }
            
            if result == true {
                complitionHandler(true, nil)
            } else {
                complitionHandler(false, LoginError.unknown)
            }
        }
    }
    
    func linkWithFacebookFrom(viewController: UIViewController, complitionHandler: @escaping (Bool, Error?) -> ()) {
        facebookManager.linkFrom(viewController: viewController) { (result, error) in
            if let error = error {
                complitionHandler(false, error)
                return
            }
            
            if result == true {
                complitionHandler(true, nil)
            } else {
                complitionHandler(false, LoginError.unknown)
            }
        }
    }
    
    func loginWithTwitter(complitionHandler: @escaping (Bool, Error?) -> ()) {
        twitterManager.login { (result, error) in
            if let error = error {
                complitionHandler(false, error)
                return
            }
            
            if result == true {
                complitionHandler(true, nil)
            } else {
                complitionHandler(false, LoginError.unknown)
            }
        }
        
    }
    
    func linkWithTwitter(complitionHandler: @escaping (Bool, Error?) -> ()) {
        twitterManager.link { (result, error) in
            if let error = error {
                complitionHandler(false, error)
                return
            }
            
            if result == true {
                complitionHandler(true, nil)
            } else {
                complitionHandler(false, LoginError.unknown)
            }
        }
        
    }
    
    func verify(phoneNumber: String, from viewController: UIViewController, callback: @escaping (Bool) -> Void) -> Void {
        phoneAuthManager.verify(phoneNumber: phoneNumber, from: viewController) { (result) in
            callback(result)
        }
    }
    
    func verify(verificationCode: String, callback: @escaping (Bool) -> Void) -> Void {
        phoneAuthManager.verify(verificationCode: verificationCode) { (result) in
            callback(result)
        }
    }
    
    func signOut(complitionHandler: (Bool) -> ()) -> () {
        do {
            googleManager.logout()
            facebookManager.logout()
            twitterManager.logout()
            
            try Auth.auth().signOut()
        } catch {
            complitionHandler(false)
        }
        
        complitionHandler(true)
    }
    
    func getLinkedAccounts() {
        guard let user = firebaseManager.currentUser, let emailId = user.email else {
            print("Can not get the users mail ID")
            return
        }
        
        print("emailId: \(emailId)")
        
        firebaseManager.fetchLinkedAccountsWithProvider(emailId) { (accounts, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            print("accounts: \(accounts)")
        }
        //
        //        firebaseManager.fetchProvidersForEmail(emailId) { (providers, error) in
        //            if let error = error {
        //                print(error.localizedDescription)
        //                return
        //            }
        //
        //            print("providers: \(providers)")
        //        }
    }
}
