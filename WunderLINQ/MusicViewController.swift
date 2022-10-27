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
import MediaPlayer
import StoreKit

class MusicViewController: UIViewController, SPTAppRemotePlayerStateDelegate {

    var timer = Timer()
    var seconds = 10
    var isTimerRunning = false
    
    @IBOutlet weak var imageAlbum: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var lastButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    let playImage = UIImage(named: "playback_play")
    let pauseImage = UIImage(named: "playback_pause")
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        switch(UserDefaults.standard.integer(forKey: "darkmode_preference")){
        case 0:
            //OFF
            return .default
        case 1:
            //On
            return .lightContent
        default:
            //Default
            if #available(iOS 13.0, *) {
                if traitCollection.userInterfaceStyle == .light {
                    return .darkContent
                } else {
                    return .lightContent
                }
            } else {
                return .default
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        switch(UserDefaults.standard.integer(forKey: "darkmode_preference")){
        case 0:
            //OFF
            if #available(iOS 13.0, *) {
                overrideUserInterfaceStyle = .light
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.isNavigationBarHidden = false
            } else {
                Theme.default.apply()
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.isNavigationBarHidden = false
            }
        case 1:
            //On
            if #available(iOS 13.0, *) {
                overrideUserInterfaceStyle = .dark
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.isNavigationBarHidden = false
            } else {
                Theme.dark.apply()
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.isNavigationBarHidden = false
            }
        default:
            //Default
            if #available(iOS 13.0, *) {
            } else {
                Theme.default.apply()
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.isNavigationBarHidden = false
            }
        }
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let touchRecognizer = UITapGestureRecognizer(target: self, action:  #selector(onTouch))
        self.view.addGestureRecognizer(touchRecognizer)
        
        let backBtn = UIButton()
        backBtn.setImage(UIImage(named: "Left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        if #available(iOS 13.0, *) {
            backBtn.tintColor = UIColor(named: "imageTint")
        }
        backBtn.addTarget(self, action: #selector(leftScreen), for: .touchUpInside)
        let backButton = UIBarButtonItem(customView: backBtn)
        let backButtonWidth = backButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        backButtonWidth?.isActive = true
        let backButtonHeight = backButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        backButtonHeight?.isActive = true
        
        let forwardBtn = UIButton()
        forwardBtn.setImage(UIImage(named: "Right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        if #available(iOS 13.0, *) {
            forwardBtn.tintColor = UIColor(named: "imageTint")
        }
        forwardBtn.addTarget(self, action: #selector(rightScreen), for: .touchUpInside)
        let forwardButton = UIBarButtonItem(customView: forwardBtn)
        let forwardButtonWidth = forwardButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        forwardButtonWidth?.isActive = true
        let forwardButtonHeight = forwardButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        forwardButtonHeight?.isActive = true
        self.navigationItem.title = NSLocalizedString("music_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton]
        self.navigationItem.rightBarButtonItems = [forwardButton]

        if UserDefaults.standard.bool(forKey: "display_brightness_preference") {
            UIScreen.main.brightness = CGFloat(1.0)
        } else {
            UIScreen.main.brightness = CGFloat(UserDefaults.standard.float(forKey: "systemBrightness"))
        }
        
        let musicApp = UserDefaults.standard.integer(forKey: "musicplayer_preference")
        switch (musicApp){
        case 0: // Apple Music
            appleMusicPlayer.prepareToPlay()
            
            self.appleMusicTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(MusicViewController.appleMusicTimerFired(_:)), userInfo: nil, repeats: true)
            self.appleMusicTimer.tolerance = 0.1
            
            appleMusicPlayer.beginGeneratingPlaybackNotifications()
            
            NotificationCenter.default.addObserver(self, selector:#selector(MusicViewController.appleUpdateNowPlayingInfo), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
            
            if (appleMusicPlayer.playbackState == MPMusicPlaybackState.playing) {
                updatePlayPauseButtonState(false)
            } else {
                updatePlayPauseButtonState(true)
            }
            break
        case 1: // Spotify
            spotifyGetPlayerState()
            break
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isTimerRunning == false {
            runTimer()
        }
        /* TESTING: Read playlists
         
        let myPlaylistsQuery = MPMediaQuery.playlists()
        let playlists = myPlaylistsQuery.collections

        for playlist in playlists! {
            print(playlist.value(forProperty: MPMediaPlaylistPropertyName) ?? "No name")
        }
         */
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let musicApp = UserDefaults.standard.integer(forKey: "musicplayer_preference")
        switch (musicApp){
        case 0: // Apple Music
            // Do nothing
            break
        case 1: // Spotify
            spotifyGetPlayerState()
            break
        default:
            break
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
        seconds = 0
        // Show the navigation bar on other view controllers
        DispatchQueue.main.async(){
            self.navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showError(_ errorDescription: String) {
        let alert = UIAlertController(title: "Error!", message: errorDescription, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
    }
    
    @objc func updateTimer() {
        if seconds < 1 {
            timer.invalidate()
            isTimerRunning = false
            seconds = 10
            // Hide the navigation bar on the this view controller
            DispatchQueue.main.async(){
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                if #available(iOS 13.0, *) {
                    switch(UserDefaults.standard.integer(forKey: "darkmode_preference")){
                    case 0:
                        //OFF
                        self.navigationController?.setStatusBar(backgroundColor: .white)
                    case 1:
                        //On
                        self.navigationController?.setStatusBar(backgroundColor: .black)
                    default:
                        //Default
                        if self.traitCollection.userInterfaceStyle == .light {
                            self.navigationController?.setStatusBar(backgroundColor: .white)
                        } else {
                            self.navigationController?.setStatusBar(backgroundColor: .black)
                        }
                     }
                }
                self.navigationController?.navigationBar.setNeedsLayout()
            }
        } else {
            seconds -= 1
        }
    }
    
    @objc func onTouch() {
        DispatchQueue.main.async(){
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
        if isTimerRunning == false {
            runTimer()
        }
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            leftScreen()
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            rightScreen()
        }
    }
    
    override var keyCommands: [UIKeyCommand]? {
        let commands = [
            UIKeyCommand(input: "\u{d}", modifierFlags:[], action: #selector(playPause), discoverabilityTitle: "Play/Pause"),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags:[], action: #selector(leftScreen), discoverabilityTitle: "Go left"),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags:[], action: #selector(rightScreen), discoverabilityTitle: "Go right"),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags:[], action: #selector(nextSong), discoverabilityTitle: "Next Song"),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags:[], action: #selector(previousSong), discoverabilityTitle: "Previous Song")
        ]
        return commands
    }
    
    @objc func leftScreen() {
        if UserDefaults.standard.bool(forKey: "display_dashboard_preference") {
            performSegue(withIdentifier: "musicToDash", sender: [])
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @objc func rightScreen() {
        performSegue(withIdentifier: "musicToTasks", sender: [])
    }
    
    @objc func playPause() {
        let musicApp = UserDefaults.standard.integer(forKey: "musicplayer_preference")
        switch (musicApp){
        case 0: // Apple Music
            if (appleMusicPlayer.playbackState == MPMusicPlaybackState.playing) {
                appleMusicPlayer.pause()
                updatePlayPauseButtonState(true)
                playButton.setImage(playImage, for: .normal)
                
            } else {
                appleMusicPlayer.play()
                updatePlayPauseButtonState(false)
            }
            break
        case 1: // Spotify
            if !(spotifyAppRemote.isConnected) {
                if (!spotifyAppRemote.authorizeAndPlayURI(spotifyPlayURI)) {
                    // The Spotify app is not installed, present the user with an App Store page
                    print("Spotify Not Installed")
                    showError("Spotify Not Installed")
                }
            } else if spotifyPlayerState == nil || spotifyPlayerState!.isPaused {
                if (spotifyPlayerState == nil){
                    spotifyAppRemote.authorizeAndPlayURI(spotifyPlayURI)
                } else {
                    spotifyStartPlayback()
                }
            } else {
                spotifyPausePlayback()
            }
            break
        default:
            break
        }
    }
    
    @IBAction func playButton(_ sender: UIButton) {
        playPause()
    }
    
    private func updatePlayPauseButtonState(_ paused: Bool) {
        if (paused){
            self.playButton.setImage(playImage, for: .normal)
        } else {
            self.playButton.setImage(pauseImage, for: .normal)
        }
    }
    
    @objc func previousSong() {
        let musicApp = UserDefaults.standard.integer(forKey: "musicplayer_preference")
        switch (musicApp){
        case 0: // Apple Music
            if appleMusicTrackElapsed != nil {
                if Int(appleMusicTrackElapsed) < 3 {
                    appleMusicPlayer.skipToPreviousItem()
                } else {
                    appleMusicPlayer.skipToBeginning()
                }
            }
            break
        case 1: // Spotify
            spotifySkipPrevious()
            break
        default:
            break
        }
    }
    
    @IBAction func lastButton(_ sender: UIButton) {
        previousSong()
    }
    
    @objc func nextSong() {
        let musicApp = UserDefaults.standard.integer(forKey: "musicplayer_preference")
        switch (musicApp){
        case 0: // Apple Music
            appleMusicPlayer.skipToNextItem()
            break
        case 1: // Spotify
            spotifySkipNext()
            break
        default:
            break
        }
    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        nextSong()
    }
    
    private func enableInterface(_ enabled: Bool = true) {
        if (self.viewIfLoaded?.window != nil ) {
            nextButton.isEnabled = enabled
            lastButton.isEnabled = enabled

            if (!enabled) {
                imageAlbum.image = nil
            }
        }
    }
    
    
    // MARK: - Apple Music
    let appleMusicPlayer = MPMusicPlayerController.systemMusicPlayer
    var appleMusicTimer = Timer()
    var appleMusicTrackElapsed: TimeInterval!
    
    @objc func appleMusicTimerFired(_:AnyObject) {
        if let currentTrack = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem {
            // Update UI
            // Get Current Track Info
            var trackName = ""
            if currentTrack.title != nil {
                trackName = currentTrack.title!
            }
            songLabel.text = trackName
            var trackArtist = ""
            if currentTrack.artist != nil {
                trackArtist = currentTrack.artist!
            }
            artistLabel.text = trackArtist
            var trackAlbum = ""
            if currentTrack.albumTitle != nil {
                trackAlbum = currentTrack.albumTitle!
            }
            albumLabel.text = trackAlbum
            if let albumImage: MPMediaItemArtwork = currentTrack.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork{
                imageAlbum.image = albumImage.image(at: imageAlbum.bounds.size)
            }
            appleMusicTrackElapsed = appleMusicPlayer.currentPlaybackTime
        }
    }
    
    @objc func appleUpdateNowPlayingInfo(){
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(MusicViewController.appleMusicTimerFired(_:)), userInfo: nil, repeats: true)
        self.timer.tolerance = 0.1
    }
    
    // MARK: - Spotify
    private let spotifyPlayURI = ""
    private var spotifyPlayerState: SPTAppRemotePlayerState?
    private var spotifySubscribedToPlayerState: Bool = false
    
    
    var spotifyDefaultCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    self?.showError(error.localizedDescription)
                }
            }
        }
    }
    
    private func spotifyUpdateViewWithRestrictions(_ restrictions: SPTAppRemotePlaybackRestrictions) {
        nextButton.isEnabled = restrictions.canSkipNext
        lastButton.isEnabled = restrictions.canSkipPrevious
    }
    
    private func spotifyGetPlayerState() {
        print("spotifyGetSpotifyPlayerState()")
        spotifyAppRemote.playerAPI?.getPlayerState { (result, error) -> Void in
            guard error == nil else { return }
            let playerState = result as! SPTAppRemotePlayerState
            self.spotifyPlayerState = playerState
            self.spotifyUpdateViewWithPlayerState(playerState)
            self.spotifySubscribeToPlayerState()
        }
    }
    
    private func spotifySubscribeToPlayerState() {
        print("spotifySubscribeToPlayerState()")
        guard (!spotifySubscribedToPlayerState) else { return }
        spotifyAppRemote.playerAPI!.delegate = self
        spotifyAppRemote.playerAPI?.subscribe { (_, error) -> Void in
            guard error == nil else { return }
            self.spotifySubscribedToPlayerState = true
        }
    }

    private func spotifyUnsubscribeFromPlayerState() {
        print("spotifyUnsubscribeFromPlayerState()")
        guard (spotifySubscribedToPlayerState) else { return }
        spotifyAppRemote.playerAPI?.unsubscribe { (_, error) -> Void in
            guard error == nil else { return }
            self.spotifySubscribedToPlayerState = false
        }
    }
    
    private func spotifySkipNext() {
        spotifyAppRemote.playerAPI?.skip(toNext: spotifyDefaultCallback)
    }

    private func spotifySkipPrevious() {
        spotifyAppRemote.playerAPI?.skip(toPrevious: spotifyDefaultCallback)
    }
    
    private func spotifyStartPlayback() {
        
        spotifyAppRemote.playerAPI?.resume(spotifyDefaultCallback)
    }

    private func spotifyPausePlayback() {
        spotifyAppRemote.playerAPI?.pause(spotifyDefaultCallback)
    }
    
    // MARK: - Image API

    private func spotifyFetchAlbumArtForTrack(_ track: SPTAppRemoteTrack, callback: @escaping (UIImage) -> Void ) {
        spotifyAppRemote.imageAPI?.fetchImage(forItem: track, with:CGSize(width: 1000, height: 1000), callback: { (image, error) -> Void in
            guard error == nil else { return }

            let image = image as! UIImage
            callback(image)
        })
    }
    
    var spotifyAppRemote: SPTAppRemote {
        get {
            return AppDelegate.sharedInstance.spotifyAppRemote
        }
    }
    
    // MARK: - <SPTAppRemotePlayerStateDelegate>

    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        print("Spotify: playerStateDidChange")
        self.spotifyPlayerState = playerState
        spotifyUpdateViewWithPlayerState(playerState)
    }
    
    private func spotifyUpdateViewWithPlayerState(_ playerState: SPTAppRemotePlayerState) {
        if (self.viewIfLoaded?.window != nil ) {
            updatePlayPauseButtonState(playerState.isPaused)
                songLabel.text = playerState.track.name
                artistLabel.text = playerState.track.artist.name
                albumLabel.text = playerState.track.album.name
                spotifyFetchAlbumArtForTrack(playerState.track) { (image) -> Void in
                    self.imageAlbum.image = image
            }
            spotifyUpdateViewWithRestrictions(playerState.playbackRestrictions)
        }
    }
    
    func spotifyAppRemoteConnecting() {
        print("spotifyAppRemoteConnecting()")
    }

    func spotifyAppRemoteConnected() {
        print("spotifyAppRemoteConnected()")
        spotifyGetPlayerState()
        enableInterface(true)
    }

    func spotifyAppRemoteDisconnect() {
        print("spotifyAppRemoteDisconnect()")
        self.spotifySubscribedToPlayerState = false
        enableInterface(false)
    }

}
