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

import UIKit
import os.log

class SceneDelegate: UIResponder, UIWindowSceneDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {

    var window: UIWindow?
    
    private let spotifyRedirectUri = URL(string: "wunderlinq://music")!
    private let spotifyClientIdentifier = Secrets.spotify_app_id

    static private let kAccessTokenKey = "access-token-key"
    
    var spotifyAccessToken: String? {
        get { UserDefaults.standard.string(forKey: SceneDelegate.kAccessTokenKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: SceneDelegate.kAccessTokenKey)
        }
    }

    lazy var spotifyAppRemote: SPTAppRemote = {
        let configuration = SPTConfiguration(clientID: spotifyClientIdentifier, redirectURL: spotifyRedirectUri)
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = spotifyAccessToken
        appRemote.delegate = self
        return appRemote
    }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        os_log("SceneDelegate: willConnectTo")
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        if !UserDefaults.standard.bool(forKey: "firstRun") {
            let storyboard = UIStoryboard.main
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "firstRunVC")
        } else {
            window?.rootViewController = UIStoryboard.main.instantiateInitialViewController()
        }

        window?.makeKeyAndVisible()

        if let urlContext = connectionOptions.urlContexts.first {
            handleIncomingURL(urlContext.url)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        os_log("SceneDelegate: scene openURLContext")
        if let urlContext = URLContexts.first {
            handleIncomingURL(urlContext.url)
        }
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        os_log("SceneDelegate: sceneWillEnterForeground")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        os_log("SceneDelegate: sceneDidBecomeActive")
        spotifyConnect()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        os_log("SceneDelegate: sceneWillResignActive")
        musicViewController.spotifyAppRemoteDisconnect()
        spotifyAppRemote.disconnect()
    }
    
    func spotifyConnect() {
        musicViewController.spotifyAppRemoteConnecting()
        spotifyAppRemote.connect()
    }

    // MARK: Spotify Delegate Methods
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.spotifyAppRemote = appRemote
        musicViewController.spotifyAppRemoteConnected()
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        musicViewController.spotifyAppRemoteDisconnect()
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        musicViewController.spotifyAppRemoteDisconnect()
    }
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        musicViewController.spotifyAppRemotePlayerStateDidChange()
    }
    
    var musicViewController: MusicViewController {
        get {
            let controller = UIStoryboard.main.instantiateViewController(withIdentifier: "MusicViewController") as! MusicViewController
            return controller
        }
    }

    private func handleIncomingURL(_ url: URL) {
        if url.scheme == "file" {
            os_log("SceneDelegate: File URL received")
            if let navigationController = window?.rootViewController as? UINavigationController {
                let addWaypointVC = UIStoryboard.main.instantiateViewController(withIdentifier: "addWaypoint") as! AddWaypointViewController
                addWaypointVC.importFile = url
                navigationController.pushViewController(addWaypointVC, animated: true)
            }
        } else {
            os_log("SceneDelegate: Other URL received: \(url.absoluteString)")
            let parameters = spotifyAppRemote.authorizationParameters(from: url);

            if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
                spotifyAppRemote.connectionParameters.accessToken = access_token
                self.spotifyAccessToken = access_token
            } else if let errorDescription = parameters?[SPTAppRemoteErrorDescriptionKey] {
                os_log("SceneDelegate: Error: \(errorDescription)")
                musicViewController.showError(errorDescription)
            }
        }
    }
}
