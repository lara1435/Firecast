//
//  PhoneAuthManager.swift
//  Firecast
//
//  Created by Lakshmi Narayanan N on 29/10/18.
//  Copyright © 2018 Lakshmi Narayanan N. All rights reserved.
//

import Foundation
import Firebase

enum EmailLoginError: Error {
    case invalidUserName
    case invalidpassword
    case invalidCredentials
}

class EmailAuthManager {
    let firebaseManager:FirebaseBoundaries!
    
    init(firebaseManager: FirebaseBoundaries) {
        self.firebaseManager = firebaseManager
    }
}

extension EmailAuthManager {
    func signIn(userName: String, password: String, callback: @escaping (Bool, Error?) -> Void) -> Void {
        Auth.auth().signIn(withEmail: userName, password: password) { (result, error) in
            if let _ = error {
                callback(false, error)
            }
            callback(true, nil)
        }
    }
}

extension EmailAuthManager {
    func signUp(userName: String, password: String, callback: @escaping (Bool, Error?)  -> Void) -> Void {
        Auth.auth().createUser(withEmail: userName, password: password) { (result, error) in
            if let _ = error {
                callback(false, error)
            }
            callback(true, nil)
        }
    }
}
