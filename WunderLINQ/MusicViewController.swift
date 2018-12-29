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
    
    
    @IBAction func previousBtnPress(_ sender: Any) {
    }
    @IBAction func playPauseBtnPress(_ sender: Any) {
        print("play/pause touched")
        if (musicPlayer().playbackState == MPMusicPlaybackState.playing) {
            musicPlayer().pause()
            playButton.setImage(playImage, for: .normal)
            
        } else {
            musicPlayer().play()
            playButton.setImage(pauseImage, for: .normal)
        }
    }
    @IBAction func nextBtnPress(_ sender: Any) {
    }
    
    let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    var timer = Timer()
    
    var trackElapsed: TimeInterval!

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
        musicPlayer().prepareToPlay()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(MusicViewController.timerFired(_:)), userInfo: nil, repeats: true)
        self.timer.tolerance = 0.1
        
        musicPlayer().beginGeneratingPlaybackNotifications()
        
        NotificationCenter.default.addObserver(self, selector:#selector(MusicViewController.updateNowPlayingInfo), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        
        if (musicPlayer().playbackState == MPMusicPlaybackState.playing) {
            playButton.setImage(pauseImage, for: .normal)

        } else {
            playButton.setImage(playImage, for: .normal)
        }
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
    
    func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            performSegue(withIdentifier: "musicToMotorcycle", sender: [])
        }
        else if gesture.direction == UISwipeGestureRecognizerDirection.left {
            performSegue(withIdentifier: "musicToCompass", sender: [])
        }
    }
    
    override var keyCommands: [UIKeyCommand]? {
        let commands = [
            UIKeyCommand(input: "\u{d}", modifierFlags:[], action: #selector(playPause), discoverabilityTitle: "Play/Pause"),
            UIKeyCommand(input: UIKeyInputLeftArrow, modifierFlags:[], action: #selector(leftScreen), discoverabilityTitle: "Go left"),
            UIKeyCommand(input: UIKeyInputRightArrow, modifierFlags:[], action: #selector(rightScreen), discoverabilityTitle: "Go right"),
            UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags:[], action: #selector(nextSong), discoverabilityTitle: "Next Song"),
            UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags:[], action: #selector(previousSong), discoverabilityTitle: "Previous Song")
        ]
        return commands
    }
    
    @objc func leftScreen() {
        performSegue(withIdentifier: "musicToMotorcycle", sender: [])
    }
    @objc func rightScreen() {
        performSegue(withIdentifier: "musicToCompass", sender: [])
    }
    @objc func nextSong() {
        musicPlayer().skipToNextItem()
    }
    @objc func previousSong() {
        if trackElapsed != nil {
            if Int(trackElapsed) < 3 {
                musicPlayer().skipToPreviousItem()
            } else {
                musicPlayer().skipToBeginning()
            }
        }
    }
    @objc func playPause() {
        if (musicPlayer().playbackState == MPMusicPlaybackState.playing) {
            musicPlayer().pause()
            playButton.setImage(playImage, for: .normal)
            
        } else {
            musicPlayer().play()
            playButton.setImage(pauseImage, for: .normal)
        }
    }
    
    @IBAction func unwindToContainerMusicVC(segue: UIStoryboardSegue) {
        
    }

    
    @IBAction func playButton(_ sender: UIButton) {
        if (musicPlayer().playbackState == MPMusicPlaybackState.playing) {
            musicPlayer().pause()
            playButton.setImage(playImage, for: .normal)
            
        } else {
            musicPlayer().play()
            playButton.setImage(pauseImage, for: .normal)
        }
    }
    
    @IBAction func lastButton(_ sender: UIButton) {
        if trackElapsed != nil {
            if Int(trackElapsed) < 3 {
                musicPlayer().skipToPreviousItem()
            } else {
                musicPlayer().skipToBeginning()
            }
        }
    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        musicPlayer().skipToNextItem()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func timerFired(_:AnyObject) {
        if let currentTrack = MPMusicPlayerController.systemMusicPlayer().nowPlayingItem {
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
            trackElapsed = musicPlayer().currentPlaybackTime
            //let trackDuration = currentTrack.playbackDuration
            
            // Update UI
            imageAlbum.image = albumImage
            artistLabel.text = trackArtist
            songLabel.text = trackName
            albumLabel.text = trackAlbum
            
        }
    }
    
    func updateNowPlayingInfo(){
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(MusicViewController.timerFired(_:)), userInfo: nil, repeats: true)
        self.timer.tolerance = 0.1
    }

}
