import UIKit
import GoogleSignIn
import Firebase

enum GoogleError: Error {
    case invalidUser
}

enum GoogleSignInError: Error {
    case unknown
    case invalidAuthentication
}

enum GoogleSignOutError: Error {
    case unknown
}

class GoogleManager: NSObject {
    
    enum Mode {
        case create, edit
    }
    
    let firebaseManager:FirebaseBoundaries!
    var loginComplitionHandler: ((Bool, Error?) -> ())?
    var mode: Mode = .create
    
    init(firebaseManager: FirebaseBoundaries) {
        self.firebaseManager = firebaseManager
        
        super.init()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
    }
}

extension GoogleManager {
    func loginWithGoogle(callback: @escaping (Bool,  Error?) -> Void) -> Void {
        mode = .create
        GIDSignIn.sharedInstance().signIn()
        loginComplitionHandler = callback
    }
    
    func linkWithGoogle(callback: @escaping (Bool,  Error?) -> Void) -> Void {
        mode = .edit
        GIDSignIn.sharedInstance().signIn()
        loginComplitionHandler = callback
    }
    
    func logout() {
        GIDSignIn.sharedInstance()?.signOut()
    }
}

extension GoogleManager: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        if let error = error {
            self.loginComplitionHandler!(false, error)
            return
        }
        guard let authentication = user.authentication else {
            self.loginComplitionHandler!(false, GoogleSignInError.invalidAuthentication)
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        if mode == .create {
            firebaseManager.loginFirebaseWithCredential(credential) { (result, error) in
                if let error = error {
                    self.loginComplitionHandler!(false, error)
                    return
                }
                
                self.firebaseManager.persistentManager.saveGoogle(idToken: authentication.idToken, accessToken: authentication.accessToken, email: user.profile.email)
                self.loginComplitionHandler!(true, nil)
            }
        } else {
            firebaseManager.linkWithCurrentUser(credential: credential) { (result, error) in
                if let error = error {
                    self.loginComplitionHandler!(false, error)
                    return
                }
                
                self.firebaseManager.persistentManager.saveGoogle(idToken: authentication.idToken, accessToken: authentication.accessToken, email: user.profile.email)
                self.loginComplitionHandler!(true, nil)
            }
        }
       
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            self.loginComplitionHandler!(false, error)
            return
        }
    }
}

extension GoogleManager {
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: [:])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
}

