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
import SpotifyiOS
import os.log

class MusicViewController: UIViewController {
    
    var backButton: UIBarButtonItem!
    var faultsBtn: UIButton!
    var faultsButton: UIBarButtonItem!
    
    @IBOutlet weak var imageAlbum: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var lastButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    var buttons: [UIButton] = []
    
    private let notificationCenter = NotificationCenter.default
    
    let motorcycleData = MotorcycleData.shared
    let faults = Faults.shared
    
    var timer = Timer()
    var seconds = 10
    var isTimerRunning = false
    
    var refreshTimer: Timer?
    
    let playImage = UIImage(named: "playback_play")
    let pauseImage = UIImage(named: "playback_pause")

    override func viewDidLoad() {
        super.viewDidLoad()
        os_log("MusicViewController: viewDidLoad()")
        
        if UserDefaults.standard.bool(forKey: "display_brightness_preference") {
            UIScreen.main.brightness = CGFloat(1.0)
        } else {
            UIScreen.main.brightness = CGFloat(UserDefaults.standard.float(forKey: "systemBrightness"))
        }
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let touchRecognizer = UITapGestureRecognizer(target: self, action:  #selector(onTouch))
        self.view.addGestureRecognizer(touchRecognizer)
        
        buttons = [lastButton, playButton, nextButton]
        
        let backBtn = UIButton()
        backBtn.setImage(UIImage(named: "Left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        backBtn.tintColor = UIColor(named: "imageTint")
        backBtn.addTarget(self, action: #selector(leftScreen), for: .touchUpInside)
        backButton = UIBarButtonItem(customView: backBtn)
        let backButtonWidth = backButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        backButtonWidth?.isActive = true
        let backButtonHeight = backButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        backButtonHeight?.isActive = true
        
        let forwardBtn = UIButton()
        forwardBtn.setImage(UIImage(named: "Right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        forwardBtn.tintColor = UIColor(named: "imageTint")
        forwardBtn.addTarget(self, action: #selector(rightScreen), for: .touchUpInside)
        let forwardButton = UIBarButtonItem(customView: forwardBtn)
        let forwardButtonWidth = forwardButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        forwardButtonWidth?.isActive = true
        let forwardButtonHeight = forwardButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        forwardButtonHeight?.isActive = true
        faultsBtn = UIButton(type: .custom)
        let faultsImage = UIImage(named: "Alert")?.withRenderingMode(.alwaysTemplate)
        faultsBtn.setImage(faultsImage, for: .normal)
        faultsBtn.tintColor = UIColor.clear
        faultsBtn.accessibilityIgnoresInvertColors = true
        faultsBtn.addTarget(self, action: #selector(self.faultsButtonTapped), for: .touchUpInside)
        faultsButton = UIBarButtonItem(customView: faultsBtn)
        faultsButton.accessibilityRespondsToUserInteraction = false
        faultsButton.isAccessibilityElement = false
        let faultsButtonWidth = faultsButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        faultsButtonWidth?.isActive = true
        let faultsButtonHeight = faultsButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        faultsButtonHeight?.isActive = true
        // Update Buttons
        if (faults.getallActiveDesc().isEmpty){
            faultsBtn.tintColor = UIColor.clear
            faultsButton.isEnabled = false
        } else {
            faultsBtn.tintColor = UIColor(named: "motorrad_red")
            faultsButton.isEnabled = true
        }
        self.navigationItem.title = NSLocalizedString("music_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton, faultsButton]
        self.navigationItem.rightBarButtonItems = [forwardButton]
        
        let musicApp = UserDefaults.standard.integer(forKey: "musicplayer_preference")
        switch (musicApp){
        case 0: // Apple Music
            artistLabel.text = NSLocalizedString("music_apple", comment: "")
            appleMusicPlayer.prepareToPlay()
            appleMusicPlayer.beginGeneratingPlaybackNotifications()
            
            NotificationCenter.default.addObserver(self, selector:#selector(MusicViewController.appleMusicUpdateNowPlayingInfo), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
            
            if (appleMusicPlayer.playbackState == MPMusicPlaybackState.playing) {
                updatePlayPauseButtonState(false)
            } else {
                updatePlayPauseButtonState(true)
            }
            break
        case 1: // Spotify
            artistLabel.text = NSLocalizedString("music_spotify", comment: "")
            spotifyGetPlayerState()
            startRefreshTimer()
            break
        default:
            break
        }
        songLabel.text = NSLocalizedString("start_warning_pt1", comment: "")
        albumLabel.text = NSLocalizedString("start_warning_pt2", comment: "")
        notificationCenter.addObserver(self, selector:#selector(self.launchAccPage), name: NSNotification.Name("StatusUpdate"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        os_log("MusicViewController: viewWillAppear")
        if isTimerRunning == false {
            runTimer()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        os_log("MusicViewController: viewDidAppear")
        refresh()
        NotificationCenter.default.addObserver(self, selector:#selector(MusicViewController.refresh), name: UIApplication.willEnterForegroundNotification, object: UIApplication.shared)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        os_log("MusicViewController: viewWillDisappear")
        stopRefreshTimer()
        spotifyUnsubscribeFromPlayerState()
        timer.invalidate()
        seconds = 0
        // Show the navigation bar on other view controllers
        DispatchQueue.main.async(){
            self.navigationController?.setNavigationBarHidden(false, animated: animated)
        }
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        
        // Check if the next focused view is one of the buttons
        if let focusedButton = context.nextFocusedView as? UIButton, buttons.contains(focusedButton) {
            coordinator.addCoordinatedAnimations {
                var highlightColor: UIColor?
                if let colorData = UserDefaults.standard.data(forKey: "highlight_color_preference"){
                    highlightColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)
                } else {
                    highlightColor = UIColor(named: "accent")
                }
                focusedButton.backgroundColor = highlightColor
            }
        }
        
        // Check if the previously focused view is one of the buttons
        if let previouslyFocusedButton = context.previouslyFocusedView as? UIButton, buttons.contains(previouslyFocusedButton) {
            coordinator.addCoordinatedAnimations {
                previouslyFocusedButton.backgroundColor = .clear // Default background
            }
        }
    }
    
    // MARK: - Updating UI
    func updateDisplay() {
        // Update Buttons
        if (faults.getallActiveDesc().isEmpty){
            faultsBtn.tintColor = UIColor.clear
            faultsButton.isEnabled = false
        } else {
            faultsBtn.tintColor = UIColor(named: "motorrad_red")
            faultsButton.isEnabled = true
        }
    }
    
    func showError(_ errorDescription: String) {
        let alert = UIAlertController(title: "Error!", message: errorDescription, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func runTimer() {
        if UserDefaults.standard.bool(forKey: "hide_navbar_preference") {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
            isTimerRunning = true
        }
    }
    
    @objc func updateTimer() {
        if seconds < 1 {
            timer.invalidate()
            isTimerRunning = false
            seconds = 10
            // Hide the navigation bar on the this view controller
            DispatchQueue.main.async(){
                self.navigationController?.setNavigationBarHidden(true, animated: true)
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
            UIKeyCommand(input: "\u{d}", modifierFlags:[], action: #selector(playPause)),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags:[], action: #selector(leftScreen)),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags:[], action: #selector(rightScreen)),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags:[], action: #selector(nextSong)),
            UIKeyCommand(input: "+", modifierFlags:[], action: #selector(nextSong)),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags:[], action: #selector(previousSong)),
            UIKeyCommand(input: "-", modifierFlags:[], action: #selector(previousSong))
        ]
        if #available(iOS 15, *) {
            commands.forEach { $0.wantsPriorityOverSystemBehavior = true }
        }
        return commands
    }
    
    @objc func leftScreen() {
        SoundManager().playSoundEffect("directional")
        if UserDefaults.standard.bool(forKey: "display_dashboard_preference") {
            performSegue(withIdentifier: "musicToDash", sender: [])
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @objc func rightScreen() {
        SoundManager().playSoundEffect("directional")
        performSegue(withIdentifier: "musicToTasks", sender: [])
    }
    
    @objc func playPause() {
        SoundManager().playSoundEffect("enter")
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
            if spotifyAppRemote?.isConnected == false {
                os_log("MusicViewController: Spotify Not Connected")
                spotifyAppRemote?.authorizeAndPlayURI(spotifyPlayURI) { success in
                    if !success {
                        // The Spotify app is not installed, present the user with an App Store page
                        os_log("MusicViewController: Spotify Not Installed")
                        self.showError("Spotify Not Installed")
                    }
                }
            } else if spotifyPlayerState == nil || spotifyPlayerState!.isPaused {
                if (spotifyPlayerState == nil){
                    spotifyAppRemote?.authorizeAndPlayURI(spotifyPlayURI)
                } else {
                    os_log("MusicViewController: spotifyStartPlayback")
                    spotifyStartPlayback()
                }
            } else {
                os_log("MusicViewController: spotifyPausePlayback")
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
        SoundManager().playSoundEffect("directional")
        let musicApp = UserDefaults.standard.integer(forKey: "musicplayer_preference")
        switch (musicApp){
        case 0: // Apple Music
            if appleMusicTrackElapsed != nil {
                if appleMusicTrackElapsed < 3.0 {
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
        SoundManager().playSoundEffect("directional")
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
    
    @objc func refresh(){
        os_log("MusicViewController: refresh")
        let musicApp = UserDefaults.standard.integer(forKey: "musicplayer_preference")
        switch (musicApp){
        case 0: // Apple Music
            appleMusicUpdateNowPlayingInfo()
            break
        case 1: // Spotify
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                os_log("MusicViewController: Spotify refresh")
                self.spotifyGetPlayerState()
            }
            break
        default:
            break
        }
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
    
    @objc func launchAccPage(){
        if self.viewIfLoaded?.window != nil {
            let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "AccessoryViewController") as! AccessoryViewController
            self.navigationController!.pushViewController(secondViewController, animated: true)
        }
    }
    
    // MARK: - Apple Music
    let appleMusicPlayer = MPMusicPlayerController.systemMusicPlayer
    var appleMusicTimer = Timer()
    var appleMusicTrackElapsed: TimeInterval!
    
    @objc func appleMusicUpdateNowPlayingInfo(){
        os_log("MusicViewController: appleMusicUpdateNowPlayingInfo")
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
        if (appleMusicPlayer.playbackState == MPMusicPlaybackState.playing) {
            updatePlayPauseButtonState(false)
        } else {
            updatePlayPauseButtonState(true)
        }
    }
    
    // MARK: - Spotify
    private let spotifyPlayURI = ""
    private var spotifyPlayerState: SPTAppRemotePlayerState?
    private var spotifySubscribedToPlayerState: Bool = false
    
    
    var spotifyDefaultCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    os_log("MusicViewController: spotifyDefaultCallback: \(error.localizedDescription)")
                    self?.showError(error.localizedDescription)
                } else {
                    self!.spotifyGetPlayerState()
                }
            }
        }
    }
    
    private func spotifyUpdateViewWithRestrictions(_ restrictions: SPTAppRemotePlaybackRestrictions) {
        nextButton.isEnabled = restrictions.canSkipNext
        lastButton.isEnabled = restrictions.canSkipPrevious
    }
    
    private func spotifyGetPlayerState() {
        os_log("MusicViewController: spotifyGetSpotifyPlayerState()")
        spotifyAppRemote?.playerAPI?.getPlayerState { (result, error) -> Void in
            guard error == nil else {
                os_log("MusicViewController: spotifyGetSpotifyPlayerState() - error: \(error!.localizedDescription)")
                return
            }
            let playerState = result as! SPTAppRemotePlayerState
            self.spotifyPlayerState = playerState
            self.spotifyUpdateViewWithPlayerState(playerState)
        }
    }
    
    private func spotifySubscribeToPlayerState() {
        os_log("MusicViewController: spotifySubscribeToPlayerState()")
        guard (!spotifySubscribedToPlayerState) else { return }
        spotifyAppRemote?.playerAPI!.delegate = self
        spotifyAppRemote?.playerAPI?.subscribe { (_, error) -> Void in
            guard error == nil else { return }
            self.spotifySubscribedToPlayerState = true
        }
    }

    private func spotifyUnsubscribeFromPlayerState() {
        os_log("MusicViewController: spotifyUnsubscribeFromPlayerState()")
        guard (spotifySubscribedToPlayerState) else { return }
        spotifyAppRemote?.playerAPI?.unsubscribe { (_, error) -> Void in
            guard error == nil else { return }
            self.spotifySubscribedToPlayerState = false
        }
    }
    
    private func spotifySkipNext() {
        spotifyAppRemote?.playerAPI?.skip(toNext: spotifyDefaultCallback)
    }

    private func spotifySkipPrevious() {
        spotifyAppRemote?.playerAPI?.skip(toPrevious: spotifyDefaultCallback)
    }
    
    private func spotifyStartPlayback() {
        
        spotifyAppRemote?.playerAPI?.resume(spotifyDefaultCallback)
    }

    private func spotifyPausePlayback() {
        spotifyAppRemote?.playerAPI?.pause(spotifyDefaultCallback)
    }
    
    // MARK: - Image API

    private func spotifyFetchAlbumArtForTrack(_ track: SPTAppRemoteTrack, callback: @escaping (UIImage) -> Void ) {
        spotifyAppRemote?.imageAPI?.fetchImage(forItem: track, with:CGSize(width: 1000, height: 1000), callback: { (image, error) -> Void in
            guard error == nil else { return }

            let image = image as! UIImage
            callback(image)
        })
    }
    
    var spotifyAppRemote: SPTAppRemote? {
        get {
            return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.spotifyAppRemote
        }
    }
    
    private func spotifyUpdateViewWithPlayerState(_ playerState: SPTAppRemotePlayerState) {
        os_log("MusicViewController: spotifyUpdateViewWithPlayerState")
        if (self.viewIfLoaded?.window != nil ) {
            os_log("MusicViewController: spotifyUpdateViewWithPlayerState Updating")
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
        os_log("MusicViewController: spotifyAppRemoteConnecting()")
    }

    func spotifyAppRemoteConnected() {
        os_log("MusicViewController: spotifyAppRemoteConnected()")
        spotifySubscribeToPlayerState()
        spotifyGetPlayerState()
        enableInterface(true)
    }

    func spotifyAppRemoteDisconnect() {
        os_log("MusicViewController: spotifyAppRemoteDisconnect()")
        self.spotifySubscribedToPlayerState = false
        enableInterface(false)
    }
    
    func spotifyAppRemotePlayerStateDidChange() {
        os_log("MusicViewController: spotifyAppRemotePlayerStateDidChange()")
        spotifyGetPlayerState()
    }

    @objc func faultsButtonTapped() {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "FaultsTableViewController") as! FaultsTableViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // Start the timer to call refresh() every 1 second
    func startRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(refresh),
            userInfo: nil,
            repeats: true
        )
    }

    // Invalidate the timer to stop refreshing
    func stopRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    // Ensure the timer is invalidated when the view is deallocated
    deinit {
        stopRefreshTimer()
    }
}

// MARK: - SPTAppRemotePlayerStateDelegate
extension MusicViewController: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        os_log("MusicViewController: Spotify playerStateDidChange")
        self.spotifyPlayerState = playerState
        spotifyUpdateViewWithPlayerState(playerState)
    }
}
// MARK: - SPTAppRemoteUserAPIDelegate
extension MusicViewController: SPTAppRemoteUserAPIDelegate {
    func userAPI(_ userAPI: SPTAppRemoteUserAPI, didReceive capabilities: SPTAppRemoteUserCapabilities) {
        os_log("MusicViewController: Spotify userAPI")
        //updateViewWithCapabilities(capabilities)
    }
}
