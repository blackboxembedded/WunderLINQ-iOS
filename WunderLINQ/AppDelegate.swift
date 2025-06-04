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
import os.log

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var orientationLock = UIInterfaceOrientationMask.all
    
    class var sharedInstance: AppDelegate {
        get {
            return UIApplication.shared.delegate as! AppDelegate
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("AppDelegate: didFinishLaunchingWithOptions")
        registerDefaultsFromSettingsBundle()
        application.isIdleTimerDisabled = true
        GMSServices.provideAPIKey(Secrets.google_maps_api_key)

        // Customize UI
        configureAppearance()
        configureKeyboardHack()
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

        // Setup system brightness
        UserDefaults.standard.set(UIScreen.main.brightness, forKey: "systemBrightness")

        // Setup logging if enabled
        setupDebugLogging()

        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return orientationLock
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print("AppDelegate: applicationWillResignActive")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("AppDelegate: applicationDidBecomeActive")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("AppDelegate: applicationWillTerminate")
        UIScreen.main.brightness = CGFloat(UserDefaults.standard.float(forKey: "systemBrightness"))
    }

    // MARK: Helper Functions
    private func configureAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    private func configureKeyboardHack() {
        let setHardwareLayout = NSSelectorFromString("setHardwareLayout:")
        UITextInputMode.activeInputModes
            .filter { $0.responds(to: setHardwareLayout) }
            .forEach { $0.perform(setHardwareLayout, with: nil) }
    }

    private func setupDebugLogging() {
        guard UserDefaults.standard.bool(forKey: "debug_logging_preference") else { return }
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let logFilePath = (paths[0] as NSString).appendingPathComponent("wunderlinq.log")

        if let attributes = try? FileManager.default.attributesOfItem(atPath: logFilePath),
           let fileSize = attributes[FileAttributeKey.size] as? UInt64, fileSize > 20 * 1024 * 1024 {
            try? FileManager.default.removeItem(atPath: logFilePath)
        }
        freopen(logFilePath.cString(using: .ascii)!, "a+", stderr)
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
        
        //Screen Settings
        let screenSettingsUrl = Bundle.main.url(forResource: "InAppSettings", withExtension: "bundle")!.appendingPathComponent("Screens.plist")
        let screenSettingsPlist = NSDictionary(contentsOf:screenSettingsUrl)!
        let screenPreferences = screenSettingsPlist["PreferenceSpecifiers"] as! [NSDictionary]
        
        var screenDefaultsToRegister = Dictionary<String, Any>()
        
        for preference in screenPreferences {
            guard let key = preference["Key"] as? String else {
                continue
            }
            screenDefaultsToRegister[key] = preference["DefaultValue"]
        }
        UserDefaults.standard.register(defaults: screenDefaultsToRegister)
        
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
}
