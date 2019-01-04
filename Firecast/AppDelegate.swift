import UIKit
import Firebase
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        if let _ = AccountManager.shared.currentUser {
            let navigationController = mainStoryBoard.instantiateViewController(withIdentifier: "HomeNavigationController") as! UINavigationController
            window?.rootViewController = navigationController
        } else {
            let navigationController = mainStoryBoard.instantiateViewController(withIdentifier: "LoginNavigationController") as! UINavigationController
            window?.rootViewController = navigationController
        }
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return TWTRTwitter.sharedInstance().application(app, open: url, options: options)
    }
}

