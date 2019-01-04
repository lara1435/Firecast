//
//  FacebookManager.swift
//  Firecast
//
//  Created by Lakshmi Narayanan N on 22/08/18.
//  Copyright © 2018 Lakshmi Narayanan N. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

enum FaceBookError: Error {
    case invalidUser
    case unknown
}

enum FaceBookSignInError: Error {
    case unknown
    case cancelled
}

enum FaceBookSignOutError: Error {
    case unknown
}

class FacebookManager {
    let firebaseManager:FirebaseBoundaries!
    let facebookLoginManager = FBSDKLoginManager()
    
    init(firebaseManager: FirebaseBoundaries) {
        self.firebaseManager = firebaseManager
    }
}

extension FacebookManager {
    func logout() {
        facebookLoginManager.logOut()
    }
    
    func loginFrom(viewController: UIViewController, facebookLoginComplitionHandler: @escaping (Bool, Error?) -> Void) -> Void {
        facebookLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: viewController) { [unowned self] (result, error) in
            if let _ = error {
                facebookLoginComplitionHandler(false, FaceBookSignInError.unknown)
                return
            }
            guard let result = result else {
                facebookLoginComplitionHandler(false, FaceBookSignInError.unknown)
                return
            }
            if result.isCancelled == true {
                facebookLoginComplitionHandler(false, FaceBookSignInError.cancelled)
                return
            }
            
            let credential = self.firebaseManager.createFacebookCredential(withToken: FBSDKAccessToken.current().tokenString)
            self.firebaseManager.loginFirebaseWithCredential(credential, firebaseloginComplitionHandler: { (result, error) in
                guard let error = error else {
                    if result == true {
                        facebookLoginComplitionHandler(true, nil)
                        self.getEmail({ (email, error) in
                            guard let email = email else {
                                return
                            }
                            self.firebaseManager.persistentManager.saveFaceBook(token: FBSDKAccessToken.current().tokenString, email: email)
                        })
                    } else {
                        facebookLoginComplitionHandler(false, FaceBookError.unknown)
                    }
                    return
                }
                
                print(error)
                facebookLoginComplitionHandler(false, FaceBookError.invalidUser)
                
//                if error.code == 17012 {
//                    self.getEmail({ (email, error) in
//                        if let _ = error {
//                            facebookLoginComplitionHandler(false, FaceBookError.unknown)
//                            return
//                        }
//                        guard let email = email else {
//                            facebookLoginComplitionHandler(false, FaceBookError.invalidUser)
//                            return
//                        }
//                        self.firebaseManager.fetchProvidersForEmail(email, fetchProvidersComplitionHadler: { (providers, error) in
//                            if let _ = error {
//                                facebookLoginComplitionHandler(false, FaceBookError.unknown)
//                                return
//                            }
//                            guard let previousCredential = self.firebaseManager.getPreviousCredentialFrom(email: email, provider: providers[0]) else {
//                                facebookLoginComplitionHandler(false, FaceBookError.unknown)
//                                return
//                            }
//                            self.firebaseManager.loginFirebaseWithCredential(previousCredential, firebaseloginComplitionHandler: { (result, error) in
//                                if let _ = error {
//                                    facebookLoginComplitionHandler(false, FaceBookError.unknown)
//                                    return
//                                }
//                                if result == false {
//                                    facebookLoginComplitionHandler(false, FaceBookError.unknown)
//                                    return
//                                }
//                                self.firebaseManager.linkWithCurrentUser(credential: credential, firebaselinkingComplitionHandler: { (result, error) in
//                                    if let _ = error {
//                                        facebookLoginComplitionHandler(false, FaceBookError.unknown)
//                                        return
//                                    }
//                                    if result == false {
//                                        facebookLoginComplitionHandler(false, FaceBookError.unknown)
//                                        return
//                                    }
//                                    facebookLoginComplitionHandler(true, nil)
//                                    self.firebaseManager.persistentManager.saveFaceBook(token: FBSDKAccessToken.current().tokenString, email: email)
//                                })
//                            })
//                        })
//                    })
//                } else {
//                    facebookLoginComplitionHandler(false, FaceBookError.invalidUser)
//                }
            })
        }
    }
    
    func linkFrom(viewController: UIViewController, facebookLoginComplitionHandler: @escaping (Bool, Error?) -> Void) -> Void {
        facebookLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: viewController) { [unowned self] (result, error) in
            if let _ = error {
                facebookLoginComplitionHandler(false, FaceBookSignInError.unknown)
                return
            }
            guard let result = result else {
                facebookLoginComplitionHandler(false, FaceBookSignInError.unknown)
                return
            }
            if result.isCancelled == true {
                facebookLoginComplitionHandler(false, FaceBookSignInError.cancelled)
                return
            }
            
            let credential = self.firebaseManager.createFacebookCredential(withToken: FBSDKAccessToken.current().tokenString)
            self.firebaseManager.linkWithCurrentUser(credential: credential, firebaselinkingComplitionHandler: { (result, error) in
                if let _ = error {
                    facebookLoginComplitionHandler(false, FaceBookError.unknown)
                    return
                }
                if result == false {
                    facebookLoginComplitionHandler(false, FaceBookError.unknown)
                    return
                }
                facebookLoginComplitionHandler(true, nil)
                
                self.getEmail({ (email, error) in
                    guard let email = email else {
                        return
                    }
                    self.firebaseManager.persistentManager.saveFaceBook(token: FBSDKAccessToken.current().tokenString, email: email)
                })
            })
        }
    }
    
    func getEmail(_ callBack: @escaping (String?, Error?) -> ()) {
        let fbRequest = FBSDKGraphRequest(graphPath:"me", parameters: ["fields":"email"]);
        let _ = fbRequest?.start(completionHandler: { (_, result, error) in
            if let _ = error {
                callBack(nil, FaceBookError.invalidUser)
                return
            }
            
            guard let userInfo = result as? Dictionary<String, String>, let email = userInfo["email"] else {
                callBack(nil, FaceBookError.invalidUser)
                return
            }
            
            callBack(email, nil)
        })
    }
}
