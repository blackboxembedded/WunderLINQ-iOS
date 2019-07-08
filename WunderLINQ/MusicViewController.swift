//
//  MusicViewController.swift
//  WunderLINQ
//
//  Created by Keith Conger on 8/16/17.
//  Copyright © 2017 Black Box Embedded, LLC. All rights reserved.
//

import UIKit
import MediaPlayer

class MusicViewController: UIViewController {
    @IBOutlet weak var imageAlbum: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var lastButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    let playImage = UIImage(named: "play")
    let pauseImage = UIImage(named: "pause")
    
    var seconds = 10
    var timer = Timer()
    var isTimerRunning = false
    
    @IBAction func previousBtnPress(_ sender: Any) {
    }
    @IBAction func playPauseBtnPress(_ sender: Any) {
        print("play/pause touched")
        if (musicPlayer.playbackState == MPMusicPlaybackState.playing) {
            musicPlayer.pause()
            playButton.setImage(playImage, for: .normal)
            
        } else {
            musicPlayer.play()
            playButton.setImage(pauseImage, for: .normal)
        }
    }
    @IBAction func nextBtnPress(_ sender: Any) {
    }
    
    let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    var musicTimer = Timer()
    
    var trackElapsed: TimeInterval!
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if UserDefaults.standard.bool(forKey: "nightmode_preference") {
            print("StausBarStyle: Setting lightContent")
            return .lightContent
        } else {
            print("StausBarStyle: Setting default")
            return .default
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.bool(forKey: "nightmode_preference") {
            Theme.dark.apply()
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.isNavigationBarHidden = false
        } else {
            Theme.default.apply()
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.isNavigationBarHidden = false
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
        backBtn.addTarget(self, action: #selector(leftScreen), for: .touchUpInside)
        let backButton = UIBarButtonItem(customView: backBtn)
        let backButtonWidth = backButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        backButtonWidth?.isActive = true
        let backButtonHeight = backButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        backButtonHeight?.isActive = true
        
        let forwardBtn = UIButton()
        forwardBtn.setImage(UIImage(named: "Right")?.withRenderingMode(.alwaysTemplate), for: .normal)
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

        // Do any additional setup after loading the view.
        musicPlayer.prepareToPlay()
        
        self.musicTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(MusicViewController.timerFired(_:)), userInfo: nil, repeats: true)
        self.musicTimer.tolerance = 0.1
        
        musicPlayer.beginGeneratingPlaybackNotifications()
        
        NotificationCenter.default.addObserver(self, selector:#selector(MusicViewController.updateNowPlayingInfo), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        
        if (musicPlayer.playbackState == MPMusicPlaybackState.playing) {
            playButton.setImage(pauseImage, for: .normal)

        } else {
            playButton.setImage(playImage, for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isTimerRunning == false {
            runTimer()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer.invalidate()
        seconds = 0
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Handling User Interaction
    /*
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    */
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            navigationController?.popToRootViewController(animated: true)
            //performSegue(withIdentifier: "musicToMotorcycle", sender: [])
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            performSegue(withIdentifier: "musicToTasks", sender: [])
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
        navigationController?.popToRootViewController(animated: true)
        //performSegue(withIdentifier: "musicToMotorcycle", sender: [])
    }
    @objc func rightScreen() {
        performSegue(withIdentifier: "musicToTasks", sender: [])
    }
    @objc func nextSong() {
        musicPlayer.skipToNextItem()
    }
    @objc func previousSong() {
        if trackElapsed != nil {
            if Int(trackElapsed) < 3 {
                musicPlayer.skipToPreviousItem()
            } else {
                musicPlayer.skipToBeginning()
            }
        }
    }
    @objc func playPause() {
        if (musicPlayer.playbackState == MPMusicPlaybackState.playing) {
            musicPlayer.pause()
            playButton.setImage(playImage, for: .normal)
            
        } else {
            musicPlayer.play()
            playButton.setImage(pauseImage, for: .normal)
        }
    }
    
    @IBAction func unwindToContainerMusicVC(segue: UIStoryboardSegue) {
        
    }

    
    @IBAction func playButton(_ sender: UIButton) {
        if (musicPlayer.playbackState == MPMusicPlaybackState.playing) {
            musicPlayer.pause()
            playButton.setImage(playImage, for: .normal)
            
        } else {
            musicPlayer.play()
            playButton.setImage(pauseImage, for: .normal)
        }
    }
    
    @IBAction func lastButton(_ sender: UIButton) {
        if trackElapsed != nil {
            if Int(trackElapsed) < 3 {
                musicPlayer.skipToPreviousItem()
            } else {
                musicPlayer.skipToBeginning()
            }
        }
    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        musicPlayer.skipToNextItem()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func timerFired(_:AnyObject) {
        if let currentTrack = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem {
            // Get Current Track Info
            var trackName = ""
            if currentTrack.title != nil {
                trackName = currentTrack.title!
            }
            var trackArtist = ""
            if currentTrack.artist != nil {
                trackArtist = currentTrack.artist!
            }
            var trackAlbum = ""
            if currentTrack.albumTitle != nil {
                trackAlbum = currentTrack.albumTitle!
            }
            let albumImage = currentTrack.artwork?.image(at: imageAlbum.bounds.size)
            trackElapsed = musicPlayer.currentPlaybackTime
            //let trackDuration = currentTrack.playbackDuration
            
            // Update UI
            imageAlbum.image = albumImage
            artistLabel.text = trackArtist
            songLabel.text = trackName
            albumLabel.text = trackAlbum
            
        }
    }
    
    @objc func updateNowPlayingInfo(){
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(MusicViewController.timerFired(_:)), userInfo: nil, repeats: true)
        self.timer.tolerance = 0.1
    }
    
    @objc func onTouch() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        if isTimerRunning == false {
            runTimer()
        }
    }
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
    }
    
    @objc func updateTimer() {
        if seconds < 1 {
            timer.invalidate()
            //Send alert to indicate "time's up!"
            isTimerRunning = false
            seconds = 10
            // Hide the navigation bar on the this view controller
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            seconds -= 1
        }
    }
}
