import UIKit
import Firebase

enum PhoneError: Error {
    case invalidUser
}

enum PhoneSignInError: Error {
    case unknown
}

enum PhoneSignOutError: Error {
    case unknown
}

class PhoneAuthManager {
    let firebaseManager:FirebaseBoundaries!
    
    init(firebaseManager: FirebaseBoundaries) {
        self.firebaseManager = firebaseManager
    }
}

extension PhoneAuthManager {
    func verify(phoneNumber: String, from viewController: UIViewController, callback: @escaping (Bool) -> Void) -> Void {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let _ = error {
                callback(false)
                return
            }
            
            guard let verificationId = verificationID else {
                callback(false)
                return
            }
            
            UserDefaults.standard.set(verificationId, forKey: "authVerificationID")
            UserDefaults.standard.synchronize()
            callback(true)
        }
    }
    
    func verify(verificationCode: String, callback: @escaping (Bool) -> Void) -> Void {
        guard let verificationId = UserDefaults.standard.string(forKey: "authVerificationID") else {
            callback(false)
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: verificationCode)
        
        guard let _ = Auth.auth().currentUser else {
            loginUsingCredential(credential) { (result) in
                callback(result)
            }
            return
        }
        
        linkWithCurrentUser(credential) { (result) in
            callback(result)
        }
    }
}

extension PhoneAuthManager {
    func loginUsingCredential(_ credential: AuthCredential, callback: @escaping (Bool) -> Void) -> Void {
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let _ = error {
                callback(false)
                return
            }
            callback(true)
        }
    }
    
    func linkWithCurrentUser(_ credential: AuthCredential, callback: @escaping (Bool) -> Void) -> Void {
        Auth.auth().currentUser?.linkAndRetrieveData(with: credential) { (authResult, error) in
            print(authResult ?? "")
            if let error = error {
                print(error)
                callback(false)
            }
            callback(true)
        }
    }
}
