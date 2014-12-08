//
//  AppDelegate.swift
//

import UIKit
import CoreLocation
import Fabric
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let url = URL()

    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        //
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent;

        // Override point for customization after application launch.
        Fabric.with([Twitter()])

        // Check if the user is logged in or not to present the sign in screen.
        if Twitter.sharedInstance().session() == nil {
            let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
            let signInViewController: AnyObject! = storyboard.instantiateViewControllerWithIdentifier("LoginController")
            self.window?.rootViewController = signInViewController as? UIViewController
        }

        return true
    }

    func applicationWillResignActive(application: UIApplication!) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication!) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication!) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication!) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication!) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // location stuff
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        //println(newLocation.coordinate.latitude)
        //println(newLocation.coordinate.longitude)
        //let latitude  = String(format: "%f", newLocation.coordinate.latitude)
        //let longitude = String(format: "%f", newLocation.coordinate.latitude)
        //url.geo(latitude, lng: longitude)
    }

}

