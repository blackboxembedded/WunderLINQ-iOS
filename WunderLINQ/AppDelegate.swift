/*
WunderLINQ Client Application
Copyright (C) 2020  Keith Conger, Black Box Embedded, LLC

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

import AVFoundation
import Contacts
import MediaPlayer
import Photos
import UIKit
import GoogleMaps
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, SPTAppRemoteDelegate {

    private let spotifyRedirectUri = URL(string:"wunderlinq://music")!
    private let spotifyClientIdentifier = Secrets.spotify_app_id
    
    static private let kAccessTokenKey = "access-token-key"

    var spotifyAccessToken = UserDefaults.standard.string(forKey: kAccessTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(spotifyAccessToken, forKey: AppDelegate.kAccessTokenKey)
            defaults.synchronize()
        }
    }
    
    var musicViewController: MusicViewController {
        get {
            let controller = UIStoryboard.main.instantiateViewController(withIdentifier: "MusicViewController") as! MusicViewController
            return controller
        }
    }
    
    lazy var spotifyAppRemote: SPTAppRemote = {
        let configuration = SPTConfiguration(clientID: self.spotifyClientIdentifier, redirectURL: self.spotifyRedirectUri)
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.spotifyAccessToken
        appRemote.delegate = self
        return appRemote
    }()
    
    class var sharedInstance: AppDelegate {
        get {
            return UIApplication.shared.delegate as! AppDelegate
        }
    }
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) ->
    Bool {
        //Read and populate defaults
        registerDefaultsFromSettingsBundle()
        
        // Keep screen unlocked
        application.isIdleTimerDisabled = true
        GMSServices.provideAPIKey(Secrets.google_maps_api_key)
        
        // Customize Application Look
        switch(UserDefaults.standard.integer(forKey: "darkmode_preference")){
        case 0:
            //OFF
            if #available(iOS 13.0, *) {
                window?.overrideUserInterfaceStyle = .light
            } else {
                Theme.default.apply()
            }
        case 1:
            //On
            if #available(iOS 13.0, *) {
                window?.overrideUserInterfaceStyle = .dark
            } else {
                Theme.dark.apply()
            }
        default:
            //Default
            if #available(iOS 13.0, *) {
            } else {
                Theme.default.apply()
            }
         }
    
        if #available(iOS 13, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        
        //Hack to enable Virtual Keyboard
        let setHardwareLayout = NSSelectorFromString("setHardwareLayout:")
        UITextInputMode.activeInputModes
        // Filter `UIKeyboardInputMode`s.
        .filter({ $0.responds(to: setHardwareLayout) })
        .forEach { $0.perform(setHardwareLayout, with: nil) }
    
        //Lock app orientation
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
        
        // Get and store system brightness so we can reset.
        UserDefaults.standard.set(UIScreen.main.brightness, forKey: "systemBrightness")
        
        // Create and write to log file
        if UserDefaults.standard.bool(forKey: "debug_logging_preference") {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0]
            let fileName = "wunderlinq.log"
            let logFilePath = (documentsDirectory as NSString).appendingPathComponent(fileName)
            
            let fileManager = FileManager.default
            
            do {
                let attributes = try fileManager.attributesOfItem(atPath: logFilePath)
                let fileSize = attributes[FileAttributeKey.size] as! UInt64
                
                if fileSize > 20 * 1024 * 1024 {
                    try fileManager.removeItem(atPath: logFilePath)
                    NSLog("AppDelegate: File deleted successfully")
                } else {
                    NSLog("AppDelegate: File is not over 20MB")
                }
            } catch {
                NSLog("AppDelegate: Error: \(error)")
            }
            freopen(logFilePath.cString(using: String.Encoding.ascii)!, "a+", stderr)
        }
        
        if !UserDefaults.standard.bool(forKey: "firstRun") {

             let storyboard = UIStoryboard.main
             let viewController = storyboard.instantiateViewController(withIdentifier: "firstRunVC")
             self.window?.rootViewController = viewController
             self.window?.makeKeyAndVisible()
        }

        return true
    }
    
    // set orientations you want to be allowed in this property by default
    var orientationLock = UIInterfaceOrientationMask.all
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        NSLog("AppDelegate: applicationWillResignActive")
        if UserDefaults.standard.bool(forKey: "firstRun") {
            musicViewController.spotifyAppRemoteDisconnect()
            spotifyAppRemote.disconnect()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if UserDefaults.standard.bool(forKey: "firstRun") {
            NSLog("AppDelegate: starting spotifyConnect()")
            self.spotifyConnect();
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        UIScreen.main.brightness = CGFloat(UserDefaults.standard.float(forKey: "systemBrightness"))
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
        
        // Determine who sent the URL.
        let sendingAppID = options[.sourceApplication]
        NSLog("AppDelegate: source application:  \(sendingAppID ?? "Unknown")")
        NSLog("AppDelegate: URL: " + url.absoluteString)
        NSLog("AppDelegate: Scheme: \(url.scheme ?? "wunderlinq")")
        if (url.scheme == "file"){
            //Check if GPX file and import
            NSLog("AppDelegate: File URL sent")
            let rootViewController = self.window!.rootViewController as! UINavigationController

            let addWaypointViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "addWaypoint") as! AddWaypointViewController
            addWaypointViewController.importFile = url
            rootViewController.pushViewController(addWaypointViewController, animated: true)
            
        } else {
            let parameters = spotifyAppRemote.authorizationParameters(from: url);

            if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
                spotifyAppRemote.connectionParameters.accessToken = access_token
                self.spotifyAccessToken = access_token
            } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
                NSLog("AppDelegate: AppDelegate Spotify Error: " + error_description)
                musicViewController.showError(error_description)
            }
        }
        
        return true
    }
    
    func registerDefaultsFromSettingsBundle() {
        // Main Settings
        let rootSettingsUrl = Bundle.main.url(forResource: "InAppSettings", withExtension: "bundle")!.appendingPathComponent("Root.plist")
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
        let gridSettingsUrl = Bundle.main.url(forResource: "InAppSettings", withExtension: "bundle")!.appendingPathComponent("Grid.plist")
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
        let taskSettingsUrl = Bundle.main.url(forResource: "InAppSettings", withExtension: "bundle")!.appendingPathComponent("Tasks.plist")
        let taskSettingsPlist = NSDictionary(contentsOf:taskSettingsUrl)!
        let taskPreferences = taskSettingsPlist["PreferenceSpecifiers"] as! [NSDictionary]
        
        var taskaDefaultsToRegister = Dictionary<String, Any>()
        
        for preference in taskPreferences {
            guard let key = preference["Key"] as? String else {
                continue
            }
            taskaDefaultsToRegister[key] = preference["DefaultValue"]
        }
        UserDefaults.standard.register(defaults: taskaDefaultsToRegister)
        
        //Integrations Settings
        let integrationsSettingsUrl = Bundle.main.url(forResource: "InAppSettings", withExtension: "bundle")!.appendingPathComponent("Integrations.plist")
        let integrationsSettingsPlist = NSDictionary(contentsOf:integrationsSettingsUrl)!
        let integrationsPreferences = integrationsSettingsPlist["PreferenceSpecifiers"] as! [NSDictionary]
        
        var integrationsDefaultsToRegister = Dictionary<String, Any>()
        
        for preference in integrationsPreferences {
            guard let key = preference["Key"] as? String else {
                continue
            }
            integrationsDefaultsToRegister[key] = preference["DefaultValue"]
        }
        UserDefaults.standard.register(defaults: integrationsDefaultsToRegister)
    }
    
    func spotifyConnect() {
        NSLog("AppDelegate: spotifyConnect()")
        musicViewController.spotifyAppRemoteConnecting()
        spotifyAppRemote.connect()
    }
    
    // MARK: Spotify AppRemoteDelegate
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        NSLog("AppDelegate: appRemoteDidEstablishConnection")
        self.spotifyAppRemote = appRemote
        musicViewController.spotifyAppRemoteConnected()
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        NSLog("AppDelegate: didFailConnectionAttemptWithError: " + error.debugDescription)
        musicViewController.spotifyAppRemoteDisconnect()
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        NSLog("AppDelegate: didDisconnectWithError")
        musicViewController.spotifyAppRemoteDisconnect()
    }
}

