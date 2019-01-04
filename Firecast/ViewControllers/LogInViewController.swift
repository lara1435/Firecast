import UIKit

import Firebase
import GoogleSignIn
import FBSDKLoginKit

class LogInViewController: UIViewController {

    // MARK:- IBOutlets
    
    @IBOutlet weak var twitterButton: UIButton!
    
    // MARK:- Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PhoneNumberLogin" {
            let phoneLoginViewController = (segue.destination as! UINavigationController).viewControllers[0] as! PhoneLoginViewController
            phoneLoginViewController.presenterViewController = self
        }
    }
    
    // MARK:- IB Actions
    
    @IBAction func facebookSignInButtonAction(_ sender: Any) {
        AccountManager.shared.loginWithFacebookFrom(viewController: self) { [unowned self] (result, error) in
            if error != nil {
                self.showLogInError()
                return
            }
            
            if result == true {
                self.showHomePage()
            } else {
                self.showLogInError()
            }
        }
    }
    
    @IBAction func googleSignInButtonAction(_ sender: Any) {
        AccountManager.shared.loginWithGoogle { [unowned self] (result, error) in
            if error != nil {
                self.showLogInError()
                return
            }
            
            if result == true {
                self.showHomePage()
            } else {
                self.showLogInError()
            }
        }
    }
    
    @IBAction func anonymousButtonAction(_ sender: Any) {
        AccountManager.shared.doAnonymousLogin { [unowned self] (result, error) in
            if let _ = error {
                self.showLogInError()
                return
            }
            
            if result == true {
                self.showHomePage()
            } else {
                self.showLogInError()
            }
        }
    }
    
    @IBAction func twitterSignInButtonAction(_ sender: Any) {
        AccountManager.shared.loginWithTwitter { [unowned self] (result, error) in
            if error != nil {
                self.showLogInError()
                return
            }
            
            if result == true {
                self.showHomePage()
            } else {
                self.showLogInError()
            }
        }
    }
    
    @IBAction func withOutLoginButtonAction(_ sender: Any) {
        self.showHomePage()
    }
}

extension LogInViewController {
    func showHomePage() {
        if let _ = self.navigationController?.presentingViewController {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let navigationController = mainStoryBoard.instantiateViewController(withIdentifier: "HomeNavigationController") as! UINavigationController
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    func showLogInError() {
        let alert = UIAlertController(title: "Error", message: "Can not login, Please try again", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension LogInViewController: GIDSignInUIDelegate {}
