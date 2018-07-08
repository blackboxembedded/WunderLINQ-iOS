//
//  MusicViewController.swift
//  WunderLINQ
//
//  Created by Keith Conger on 8/16/17.
//  Copyright © 2017 Keith Conger. All rights reserved.
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
    
    
    let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    var timer = Timer()
    
    var trackElapsed: TimeInterval!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        musicPlayer().prepareToPlay()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(MusicViewController.timerFired(_:)), userInfo: nil, repeats: true)
        self.timer.tolerance = 0.1
        
        musicPlayer().beginGeneratingPlaybackNotifications()
        
        NotificationCenter.default.addObserver(self, selector:#selector(MusicViewController.updateNowPlayingInfo), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        
        if (musicPlayer().playbackState == MPMusicPlaybackState.playing) {
            playButton.setTitle("Pause",for: .normal)
            playButton.setImage(pauseImage, for: .normal)

        } else {
            playButton.setTitle("Play",for: .normal)
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
        print("leftScreen called")
        performSegue(withIdentifier: "unwindToCompass", sender: [])
    }
    @objc func rightScreen() {
        print("rightScreen called")
        performSegue(withIdentifier: "musicToQuickTasks", sender: [])
    }
    @objc func nextSong() {
        print("nextSong called")
        musicPlayer().skipToNextItem()
    }
    @objc func previousSong() {
        print("previousSong called")
        if Int(trackElapsed) < 3 {
            musicPlayer().skipToPreviousItem()
        } else {
            musicPlayer().skipToBeginning()
        }
    }
    @objc func playPause() {
        print("playPause called")
        if (musicPlayer().playbackState == MPMusicPlaybackState.playing) {
            musicPlayer().pause()
            playButton.setTitle("Play",for: .normal)
            playButton.setImage(playImage, for: .normal)
            
        } else {
            musicPlayer().play()
            playButton.setTitle("Pause",for: .normal)
            playButton.setImage(pauseImage, for: .normal)
        }
    }
    
    @IBAction func unwindToContainerMusicVC(segue: UIStoryboardSegue) {
        
    }

    
    @IBAction func playButton(_ sender: UIButton) {
        if (musicPlayer().playbackState == MPMusicPlaybackState.playing) {
            musicPlayer().pause()
            playButton.setTitle("Play",for: .normal)
            playButton.setImage(playImage, for: .normal)
            
        } else {
            musicPlayer().play()
            playButton.setTitle("Pause",for: .normal)
            playButton.setImage(pauseImage, for: .normal)
        }
    }
    
    @IBAction func lastButton(_ sender: UIButton) {
        if Int(trackElapsed) < 3 {
            musicPlayer().skipToPreviousItem()
        } else {
            musicPlayer().skipToBeginning()
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
            let trackName = currentTrack.title!
            let trackArtist = currentTrack.artist!
            let trackAlbum = currentTrack.albumTitle!
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
