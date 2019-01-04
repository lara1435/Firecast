//
//  FirebaseBoundaries.swift
//  Firecast
//
//  Created by Lakshmi Narayanan N on 22/08/18.
//  Copyright © 2018 Lakshmi Narayanan N. All rights reserved.
//

import Foundation
import Firebase

protocol loginBoundaries {
    var currentUser: User? { get }
    var persistentManager: PersistentBoundaries { get }
    init(persistentManager: PersistentBoundaries)
    func loginFirebaseWithCredential(_ credential: AuthCredential, firebaseloginComplitionHandler: @escaping (Bool, Error?) -> ())
    func signOut(complitionHandler: (Bool, Error?) -> ())
}

protocol linkingBoundaries {
    func linkWithCurrentUser(credential: AuthCredential, firebaselinkingComplitionHandler: @escaping (Bool, Error?) -> ())
}

protocol providerBoundaries {
    func fetchProvidersForEmail(_ email: String, fetchProvidersComplitionHadler: @escaping ([String], Error?) -> ())
}

protocol credentialBoundaries {
    func getPreviousCredentialFrom(email: String, provider: String) -> AuthCredential?
    
    func createFacebookCredential(withToken token: String) -> AuthCredential
    func createTwitterCredential(withToken token: String, secret: String) -> AuthCredential
    func createGoogleCredential(withIDToken token: String, accessToken: String) -> AuthCredential
    func createPhoneCredential(withVerificationID verificationID: String, verificationCode: String) -> AuthCredential
}

typealias FirebaseBoundaries = loginBoundaries & linkingBoundaries & providerBoundaries & credentialBoundaries
