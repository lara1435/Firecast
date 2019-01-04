//
//  PersistentManager.swift
//  Firecast
//
//  Created by Lakshmi Narayanan N on 22/08/18.
//  Copyright © 2018 Lakshmi Narayanan N. All rights reserved.
//

import UIKit

class PersistentManager: PersistentBoundaries {
    let standardUserDefaults = UserDefaults.standard
    
    func saveGoogle(idToken: String, accessToken: String, email: String) {
        standardUserDefaults.set(idToken, forKey: "GoogleIdToken")
        standardUserDefaults.set(accessToken, forKey: "GoogleAccessToken")
        standardUserDefaults.set(email, forKey: "GoogleLoginMailId")
        standardUserDefaults.synchronize()
    }
    
    func saveFaceBook(token: String, email: String) {
        standardUserDefaults.set(token, forKey: "FacebookAccessToken")
        standardUserDefaults.set(email, forKey: "FacebookLoginMailId")
        standardUserDefaults.synchronize()
    }
    
    func saveTwitter(authToken: String, authTokenSecret: String, email: String) {
        standardUserDefaults.set(authToken, forKey: "TwitterAuthToken")
        standardUserDefaults.set(authTokenSecret, forKey: "TwitterAuthTokenSecret")
        standardUserDefaults.set(email, forKey: "TwitterLoginMailId")
        standardUserDefaults.synchronize()
    }
    
    func savePhone(_ phoneNo: String, verificationID: String, verificationCode: String) {
        standardUserDefaults.set(phoneNo, forKey: "PhoneNumber")
        standardUserDefaults.set(verificationID, forKey: "PhoneVerificationID")
        standardUserDefaults.set(verificationCode, forKey: "PhoneVerificationCode")
        standardUserDefaults.synchronize()
    }
}

extension PersistentManager {
    func deleteGoogleLoginCredentialsFor(email: String) {
        standardUserDefaults.set(nil, forKey: "GoogleIdToken")
        standardUserDefaults.set(nil, forKey: "GoogleAccessToken")
        standardUserDefaults.set(nil, forKey: "GoogleLoginMailId")
        standardUserDefaults.synchronize()
    }
    
    func deleteFaceBookLoginCredentialsFor(email: String) {
        standardUserDefaults.set(nil, forKey: "FacebookAccessToken")
        standardUserDefaults.set(nil, forKey: "FacebookLoginMailId")
        standardUserDefaults.synchronize()
    }
    
    func deleteTwitterLoginCredentialsFor(email: String) {
        standardUserDefaults.set(nil, forKey: "TwitterAuthToken")
        standardUserDefaults.set(nil, forKey: "TwitterAuthTokenSecret")
        standardUserDefaults.set(nil, forKey: "TwitterLoginMailId")
        standardUserDefaults.synchronize()
    }
    
    func deletePhoneLoginCredentialsFor(_ phoneNo: String) {
        standardUserDefaults.set(nil, forKey: "PhoneNumber")
        standardUserDefaults.set(nil, forKey: "PhoneVerificationID")
        standardUserDefaults.set(nil, forKey: "PhoneVerificationCode")
        standardUserDefaults.synchronize()
    }
}

extension PersistentManager {
    func getGoogleLoginCredentialsFor(email: String) -> (String, String)?  {
        guard email == standardUserDefaults.value(forKey: "GoogleLoginMailId") as? String else {
            return nil
        }
        guard let idToken = standardUserDefaults.value(forKey: "GoogleIdToken") as? String, let accessToken = standardUserDefaults.value(forKey: "GoogleAccessToken") as? String else {
            return nil
        }
        return (idToken, accessToken)
    }
    
    func getFaceBookLoginCredentialsFor(email: String) -> String? {
        guard email == standardUserDefaults.value(forKey: "FacebookLoginMailId") as? String else {
            return nil
        }
        return standardUserDefaults.value(forKey: "FacebookAccessToken") as? String
    }
    
    func getTwitterLoginCredentialsFor(email: String) -> (String, String)? {
        guard email == standardUserDefaults.value(forKey: "TwitterLoginMailId") as? String else {
            return nil
        }
        guard let authToken = standardUserDefaults.value(forKey: "TwitterAuthToken") as? String, let authTokenSecret = standardUserDefaults.value(forKey: "TwitterAuthTokenSecret") as? String else {
            return nil
        }
        return (authToken, authTokenSecret)
    }
    
    func getPhoneLoginCredentialsFor(phone: String) -> (String, String)?  {
        guard phone == standardUserDefaults.value(forKey: "PhoneNumber") as? String else {
            return nil
        }
        guard let verificationID = standardUserDefaults.value(forKey: "PhoneVerificationID") as? String, let verificationCode = standardUserDefaults.value(forKey: "PhoneVerificationCode") as? String else {
            return nil
        }
        return (verificationID, verificationCode)
    }
}
