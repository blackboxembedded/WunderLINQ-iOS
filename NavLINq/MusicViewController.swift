//
//  MusicViewController.swift
//  NavLINq
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
            
        } else {
            playButton.setTitle("Play",for: .normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Handling User Interaction
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func playButton(_ sender: UIButton) {
        // MARK: - TODO Convert to play/pause button
        
        if (musicPlayer().playbackState == MPMusicPlaybackState.playing) {
            musicPlayer().pause()
            playButton.setTitle("Play",for: .normal)
            
        } else {
            musicPlayer().play()
            playButton.setTitle("Pause",for: .normal)
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
