//
//  AppDelegate.swift
//  WunderLINQ
//
//  Created by Keith Conger on 8/13/17.
//  Copyright © 2017 Black Box Embedded, LLC. All rights reserved.
//

import AVFoundation
import Contacts
import CoreLocation
import MediaPlayer
import Photos
import UIKit
import GoogleMaps
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) ->
        Bool {
            //Read and populate defaults
            registerDefaultsFromSettingsBundle();
            // Override point for customization after application launch.
            // Keep screen unlocked
            application.isIdleTimerDisabled = true
            GMSServices.provideAPIKey("***REMOVED***")
            // Override point for customization after application launch.
            
            Theme.current.apply()
            
            switch(UserDefaults.standard.integer(forKey: "orientation_preference")){
            case 0:
                AppUtility.lockOrientation(.all)
            case 1:
                AppUtility.lockOrientation(.landscape)
            case 2:
                AppUtility.lockOrientation(.portrait)
            default:
                AppUtility.lockOrientation(.all)
            }
            
            UserDefaults.standard.set(UIScreen.main.brightness, forKey: "systemBrightness")
            
            var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0]
            let fileName = "wunderlinq.log"
            let logFilePath = (documentsDirectory as NSString).appendingPathComponent(fileName)
            freopen(logFilePath.cString(using: String.Encoding.ascii)!, "a+", stderr)

            return true
    }
    
    /// set orientations you want to be allowed in this property by default
    var orientationLock = UIInterfaceOrientationMask.all
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        UIScreen.main.brightness = CGFloat(UserDefaults.standard.float(forKey: "systemBrightness"))
    }
    
    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any] = [:] ) -> Bool {
        
        // Determine who sent the URL.
        let sendingAppID = options[.sourceApplication]
        print("source application = \(sendingAppID ?? "Unknown")")
        
        return true
        // Process the URL.
        /*
         guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
         let albumPath = components.path,
         let params = components.queryItems else {
         print("Invalid URL or album path missing")
         return false
         }
         
         if let photoIndex = params.first(where: { $0.name == "index" })?.value {
         print("albumPath = \(albumPath)")
         print("photoIndex = \(photoIndex)")
         return true
         } else {
         print("Photo index missing")
         return false
         }
         }
         */
    }
    
    func registerDefaultsFromSettingsBundle()
    {
        // Main Settings
        let rootSettingsUrl = Bundle.main.url(forResource: "Settings", withExtension: "bundle")!.appendingPathComponent("Root.plist")
        let settingsPlist = NSDictionary(contentsOf:rootSettingsUrl)!
        let preferences = settingsPlist["PreferenceSpecifiers"] as! [NSDictionary]
        
        var defaultsToRegister = Dictionary<String, Any>()
        
        for preference in preferences {
            guard let key = preference["Key"] as? String else {
                continue
            }
            defaultsToRegister[key] = preference["DefaultValue"]
        }
        UserDefaults.standard.register(defaults: defaultsToRegister)
        
        //Grid Settings
        let gridSettingsUrl = Bundle.main.url(forResource: "Settings", withExtension: "bundle")!.appendingPathComponent("Grid.plist")
        let gridSettingsPlist = NSDictionary(contentsOf:gridSettingsUrl)!
        let gridPreferences = gridSettingsPlist["PreferenceSpecifiers"] as! [NSDictionary]
        
        var gridDefaultsToRegister = Dictionary<String, Any>()
        
        for preference in gridPreferences {
            guard let key = preference["Key"] as? String else {
                continue
            }
            gridDefaultsToRegister[key] = preference["DefaultValue"]
        }
        UserDefaults.standard.register(defaults: gridDefaultsToRegister)
        
        //Quick Task Settings
        let taskSettingsUrl = Bundle.main.url(forResource: "Settings", withExtension: "bundle")!.appendingPathComponent("Tasks.plist")
        let taskSettingsPlist = NSDictionary(contentsOf:taskSettingsUrl)!
        let taskPreferences = taskSettingsPlist["PreferenceSpecifiers"] as! [NSDictionary]
        
        var settingsDefaultsToRegister = Dictionary<String, Any>()
        
        for preference in taskPreferences {
            guard let key = preference["Key"] as? String else {
                continue
            }
            settingsDefaultsToRegister[key] = preference["DefaultValue"]
        }
        UserDefaults.standard.register(defaults: settingsDefaultsToRegister)
    }
}

