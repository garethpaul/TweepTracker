//
//  LoginController.swift
//

import UIKit
import CoreLocation
import MapKit
import Fabric
import TwitterKit


class LoginController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // Setup Login Button.
        setupLogin()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupLogin(){
        let logInButton = TWTRLogInButton(logInCompletion: {
            (session: TWTRSession!, error: NSError!) in
            // play with Twitter session

            self.performSegueWithIdentifier("ViewController", sender: self)

        })
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
    }
}

