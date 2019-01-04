import UIKit
import Firebase

enum FireBaseError: Error {
    case invalidUser
    case invalidProviders
    case invalidLinkProvider
}

enum FireBaseSignInError: Error {
    case unknown
}

enum FireBaseSignOutError: Error {
    case unknown
}

class FirebaseManager: FirebaseBoundaries {
    var persistentManager: PersistentBoundaries
    
    required init(persistentManager: PersistentBoundaries) {
        self.persistentManager = persistentManager
    }
    
    var firebase: Auth {
        return Auth.auth()
    }
    
    var currentUser: User? {
        return firebase.currentUser
    }
    
    func fetchProvidersForEmail(_ email: String, fetchProvidersComplitionHadler:@escaping ([String], Error?) -> ()) {
        var loginProviders: [String] = []
        firebase.fetchProviders(forEmail: email) { (providers, error) in
            if let _ = error {
                fetchProvidersComplitionHadler(loginProviders, FireBaseError.invalidProviders)
                return
            }
            guard let providers = providers else {
                fetchProvidersComplitionHadler(loginProviders, nil)
                return
            }
            loginProviders.append(contentsOf: providers)
            fetchProvidersComplitionHadler(loginProviders, nil)
        }
    }
    
    func loginFirebaseWithCredential(_ credential: AuthCredential, firebaseloginComplitionHandler:@escaping (Bool, Error?) -> ()) {
        firebase.signInAndRetrieveData(with: credential) {(result, error) in
            if let error = error {
                firebaseloginComplitionHandler(false, error)
                return
            }
            guard let _ = result else {
                firebaseloginComplitionHandler(false, FireBaseSignInError.unknown)
                return
            }
            
            firebaseloginComplitionHandler(true, nil)
        }
    }
    
    func linkWithCurrentUser(credential: AuthCredential, firebaselinkingComplitionHandler:@escaping (Bool, Error?) -> ()) {
        guard let user = currentUser else {
            firebaselinkingComplitionHandler(false, FireBaseError.invalidUser)
            return
        }
        user.linkAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                firebaselinkingComplitionHandler(false, error)
                return
            }
            firebaselinkingComplitionHandler(true, nil)
        }
    }
    
    func signOut(complitionHandler: (Bool, Error?) -> ()) -> () {
        do {
            try firebase.signOut()
        } catch {
            complitionHandler(false, FireBaseSignOutError.unknown)
            return
        }
        complitionHandler(true, nil)
    }
}

extension FirebaseManager {
    func getPreviousCredentialFrom(email: String, provider: String) -> AuthCredential? {
        switch provider {
        case "google.com":
            guard let loginCredential = persistentManager.getGoogleLoginCredentialsFor(email: email) else {
                return nil
            }
            let credential = createGoogleCredential(withIDToken: loginCredential.0, accessToken: loginCredential.1)
            return credential
        case "facebook.com":
            guard let loginCredential = persistentManager.getFaceBookLoginCredentialsFor(email: email) else {
                return nil
            }
            let credential = createFacebookCredential(withToken: loginCredential)
            return credential
        case "twitter.com":
            guard let loginCredential = persistentManager.getTwitterLoginCredentialsFor(email: email) else {
                return nil
            }
            let credential = createTwitterCredential(withToken: loginCredential.0, secret: loginCredential.1)
            return credential
        default:
            return nil
        }
    }
}

extension FirebaseManager {
    func createGoogleCredential(withIDToken token: String, accessToken: String) -> AuthCredential {
        let credential = GoogleAuthProvider.credential(withIDToken: token, accessToken: accessToken)
        return credential
    }
    
    func createFacebookCredential(withToken token: String) -> AuthCredential {
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        return credential
    }
    
    func createTwitterCredential(withToken token: String, secret: String) -> AuthCredential {
        let credential = TwitterAuthProvider.credential(withToken: token, secret: secret)
        return credential
    }
    
    func createPhoneCredential(withVerificationID verificationID: String, verificationCode: String) -> AuthCredential {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
        return credential
    }
}

extension FirebaseManager {
    func doAnonymousLogin(then: @escaping (Bool, Error?) -> Void) -> Void {
        firebase.signInAnonymously { (result, error) in
            if let _ = error {
                then(true, error)
                return
            }
            
            if let _ = result?.user {
                then(true, error)
                return
            }
            
            then(true, error)
        }
    }
}
