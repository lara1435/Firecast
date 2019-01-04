//
//  TwitterManager.swift
//  Firecast
//
//  Created by Lakshmi Narayanan N on 22/08/18.
//  Copyright © 2018 Lakshmi Narayanan N. All rights reserved.
//

import UIKit
import TwitterKit

enum TwitterError: Error {
    case invalidUser
    case invalidMailID
}

enum TwitterSignInError: Error {
    case unknown
    case invalidSession
}

enum TwitterSignOutError: Error {
    case unknown
}

class TwitterManager: NSObject {
    let firebaseManager:FirebaseBoundaries!
    
    init(firebaseManager: FirebaseBoundaries) {
        self.firebaseManager = firebaseManager
        TWTRTwitter.sharedInstance().start(withConsumerKey:"FTtezm2ec1pfa95dVb71F54Zr", consumerSecret:"rxaOsqQRtdRmKW7BIY8R7c0K63u9u0AaDKpJUARy1vSE1clUxj")
    }
}

extension TwitterManager: UIApplicationDelegate {
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return TWTRTwitter.sharedInstance().application(application, open: url, options: options)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return TWTRTwitter.sharedInstance().application(application, open: url, options: [:])
    }
}

extension TwitterManager {
    func logout() {
        let store = TWTRTwitter.sharedInstance().sessionStore
        
        if let userID = store.session()?.userID {
            store.logOutUserID(userID)
        }
    }
    
    func login(twitterLoginComplitionHandler: @escaping (Bool, Error?) -> Void) -> Void {
        TWTRTwitter.sharedInstance().logIn { [unowned self] (session, error) in
            if let error = error {
                twitterLoginComplitionHandler(false, error)
                return
            }
            
            guard let session = session else {
                twitterLoginComplitionHandler(false, TwitterSignInError.invalidSession)
                return
            }
            
            let credential = self.firebaseManager.createTwitterCredential(withToken: session.authToken, secret: session.authTokenSecret)
            
            self.firebaseManager.loginFirebaseWithCredential(credential, firebaseloginComplitionHandler: { (result, error) in
                guard let error = error else {
                    if result == true {
                        twitterLoginComplitionHandler(true, nil)
                        self.getEmail(session: session, callback: { (email, error) in
                            guard let email = email else {
                                return
                            }
                            self.firebaseManager.persistentManager.saveTwitter(authToken: session.authToken, authTokenSecret: session.authTokenSecret, email: email)
                        })
                    } else {
                        twitterLoginComplitionHandler(false, TwitterSignInError.unknown)
                    }
                    return
                }
                
                if error.code == 17012 {
                    self.getEmail(session: session, callback: { (email, error) in
                        if let error = error {
                            twitterLoginComplitionHandler(false, error)
                            return
                        }
                        guard let email = email else {
                            twitterLoginComplitionHandler(false, TwitterError.invalidMailID)
                            return
                        }
                        self.firebaseManager.fetchProvidersForEmail(email, fetchProvidersComplitionHadler: { (providers, error) in
                            if let error = error {
                                twitterLoginComplitionHandler(false, error)
                                return
                            }
                            guard let previousCredential = self.firebaseManager.getPreviousCredentialFrom(email: email, provider: providers[0]) else {
                                twitterLoginComplitionHandler(false, FaceBookError.unknown)
                                return
                            }
                            self.firebaseManager.loginFirebaseWithCredential(previousCredential, firebaseloginComplitionHandler: { (result, error) in
                                if let _ = error {
                                    twitterLoginComplitionHandler(false, FaceBookError.unknown)
                                    return
                                }
                                if result == false {
                                    twitterLoginComplitionHandler(false, FaceBookError.unknown)
                                    return
                                }
                                self.firebaseManager.linkWithCurrentUser(credential: credential, firebaselinkingComplitionHandler: { (result, error) in
                                    if let _ = error {
                                        twitterLoginComplitionHandler(false, FaceBookError.unknown)
                                        return
                                    }
                                    if result == false {
                                        twitterLoginComplitionHandler(false, FaceBookError.unknown)
                                        return
                                    }
                                    self.firebaseManager.persistentManager.saveTwitter(authToken: session.authToken, authTokenSecret: session.authTokenSecret, email: email)
                                    twitterLoginComplitionHandler(true, nil)
                                })
                            })
                        })
                    })
                } else {
                    twitterLoginComplitionHandler(false, TwitterError.invalidUser)
                }
            })
        }
    }
    
    func link(twitterLoginComplitionHandler: @escaping (Bool, Error?) -> Void) -> Void {
        TWTRTwitter.sharedInstance().logIn { [unowned self] (session, error) in
            if let error = error {
                twitterLoginComplitionHandler(false, error)
                return
            }
            
            guard let session = session else {
                twitterLoginComplitionHandler(false, TwitterSignInError.invalidSession)
                return
            }
            
            let credential = self.firebaseManager.createTwitterCredential(withToken: session.authToken, secret: session.authTokenSecret)
            self.firebaseManager.linkWithCurrentUser(credential: credential, firebaselinkingComplitionHandler: { (result, error) in
                if let _ = error {
                    twitterLoginComplitionHandler(false, FaceBookError.unknown)
                    return
                }
                if result == false {
                    twitterLoginComplitionHandler(false, FaceBookError.unknown)
                    return
                }
                
                self.getEmail(session: session, callback: { (email, error) in
                    guard let email = email else {
                        return
                    }
                    self.firebaseManager.persistentManager.saveTwitter(authToken: session.authToken, authTokenSecret: session.authTokenSecret, email: email)
                    twitterLoginComplitionHandler(true, nil)
                })
            })
        }
    }
    
    func getEmail(session:TWTRSession, callback: @escaping (String?, Error?) -> ()) {
        let twitterAPIClient = TWTRAPIClient(userID: session.userID)
        let request = twitterAPIClient.urlRequest(withMethod: "get", urlString: "https://api.twitter.com/1.1/account/verify_credentials.json", parameters: ["include_email": "true", "skip_status": "true"], error: nil)
        twitterAPIClient.sendTwitterRequest(request) { (response, data, error) in
            if let error = error {
                callback(nil, error)
                return
            }
            guard let data = data, let dictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let mailID = dictionary["email"] as? String else {
                callback(nil, TwitterError.invalidMailID)
                return
            }
            callback(mailID, nil)
        }
    }
}
