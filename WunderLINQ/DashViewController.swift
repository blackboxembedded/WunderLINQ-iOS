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
import WebKit

class DashViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var dashView: UIView!
    
    private let notificationCenter = NotificationCenter.default
    
    let motorcycleData = MotorcycleData.shared
    let faults = Faults.shared
    
    var webView:UIWebView = UIWebView()
    
    var timer = Timer()
    var refreshTimer = Timer()
    var seconds = 10
    var isTimerRunning = false
    
    let numDashboard = 3
    let numInfoLine = 4
    var currentDashboard = 1
    var currentInfoLine = 1
    
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
        NSLog("DashViewController: viewDidLoad()")
        if isTimerRunning == false {
            runTimer()
        }
        
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
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(longPressGestureRecognizer:)))
        self.view.addGestureRecognizer(longPressRecognizer)
        
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
        self.navigationItem.title = NSLocalizedString("dash_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton]
        self.navigationItem.rightBarButtonItems = [forwardButton]

        if UserDefaults.standard.bool(forKey: "display_brightness_preference") {
            UIScreen.main.brightness = CGFloat(1.0)
        } else {
            UIScreen.main.brightness = CGFloat(UserDefaults.standard.float(forKey: "systemBrightness"))
        }
        
        var screenSize = CGSize(width: dashView.frame.size.height, height: dashView.frame.size.width)
        if (dashView.frame.size.width > dashView.frame.size.height){
            screenSize = CGSize(width: dashView.frame.size.width, height: dashView.frame.size.height)
        }
        webView = UIWebView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        webView.delegate = self
        webView.scalesPageToFit = true
        webView.contentMode = .scaleAspectFit
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.isUserInteractionEnabled = false
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dashView.addSubview(webView)
        
        updateDashboard()

        scheduledTimerWithTimeInterval()
        
        notificationCenter.addObserver(self, selector:#selector(self.launchAccPage), name: NSNotification.Name("StatusUpdate"), object: nil)
    }
    
    func webViewDidStartLoad(_ webView: UIWebView){
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        let contentSize:CGSize = webView.scrollView.contentSize
        let webViewSize:CGSize = webView.bounds.size
        let scaleFactor:CGFloat = webViewSize.height / contentSize.height
        webView.scrollView.minimumZoomScale = scaleFactor
        webView.scrollView.maximumZoomScale = scaleFactor
        webView.scrollView.zoomScale = scaleFactor
        webView.backgroundColor = .clear
    }
    
    private func setupScreenOrientation() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let interfaceOrientation = windowScene.interfaceOrientation
            if (interfaceOrientation.isPortrait){
                // Remove next 3 lines for portrait dashboards
                let offset = (dashView.frame.size.height / 2.0) - (dashView.frame.size.width / 2.0)
                let translate = CGAffineTransform(translationX: 0.0, y: offset)
                webView.transform = translate
                // End
                webView.frame.size.width = dashView.frame.size.width
                webView.frame.size.height = dashView.frame.size.height
            } else {
                webView.transform = CGAffineTransform.identity
                webView.frame.size.width = dashView.frame.size.width
                webView.frame.size.height = dashView.frame.size.height
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.setupScreenOrientation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NSLog("DashViewController: viewWillAppear()")
        setupScreenOrientation()
        //Read last used dashboard
        let lastSelection = UserDefaults.standard.string(forKey: "lastDashboard")
        if lastSelection != nil {
            currentDashboard = Int(lastSelection ?? "1") ?? 1
        } else {
            currentDashboard = 1
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NSLog("DashViewController: viewWillDisappear()")
        timer.invalidate()
        refreshTimer.invalidate()
        seconds = 0
        // Show the navigation bar on other view controllers
        DispatchQueue.main.async(){
            self.navigationController?.setNavigationBarHidden(false, animated: animated)
        }
        // Save away current dashboard
        UserDefaults.standard.set(currentDashboard, forKey: "lastDashboard")
    }


    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }

    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }

    @objc func onTouch() {
        DispatchQueue.main.async(){
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
        if isTimerRunning == false {
            runTimer()
        }
    }
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            nextDashboard()
        }
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            leftScreen()
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            rightScreen()
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.up {
            nextInfo()
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            previousInfo()
        }
    }
    
    override var keyCommands: [UIKeyCommand]? {
        let commands = [
            UIKeyCommand(input: "\u{d}", modifierFlags:[], action: #selector(nextDashboard)),
            UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags:[], action: #selector(prevDashboard)),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags:[], action: #selector(leftScreen)),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags:[], action: #selector(rightScreen)),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags:[], action: #selector(nextInfo)),
            UIKeyCommand(input: "+", modifierFlags:[], action: #selector(nextInfo)),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags:[], action: #selector(previousInfo)),
            UIKeyCommand(input: "-", modifierFlags:[], action: #selector(previousInfo))
        ]
        if #available(iOS 15, *) {
            commands.forEach { $0.wantsPriorityOverSystemBehavior = true }
        }
        return commands
    }
    
    @objc func leftScreen() {
        SoundManager().playSoundEffect("directional")
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func rightScreen() {
        SoundManager().playSoundEffect("directional")
        if UserDefaults.standard.bool(forKey: "display_music_preference"){
            performSegue(withIdentifier: "dashToMusic", sender: [])
        } else {
            performSegue(withIdentifier: "dashToTasks", sender: [])
        }
        
    }
    
    @objc func nextInfo() {
        SoundManager().playSoundEffect("directional")
        if (currentInfoLine == numInfoLine){
            currentInfoLine = 1
        } else {
            currentInfoLine = currentInfoLine + 1
        }
        updateDashboard()
    }
    
    @objc func previousInfo() {
        SoundManager().playSoundEffect("directional")
        if (currentInfoLine == 1){
            currentInfoLine = numInfoLine
        } else {
            currentInfoLine = currentInfoLine - 1
        }
        updateDashboard()
    }
    
    @objc func nextDashboard() {
        SoundManager().playSoundEffect("enter")
        if (currentDashboard == numDashboard){
            currentDashboard = 1
        } else {
            currentDashboard = currentDashboard + 1
        }
        updateDashboard()
    }
    
    @objc func prevDashboard() {
        SoundManager().playSoundEffect("enter")
        if (currentDashboard == 1){
            currentDashboard = numDashboard
        } else {
            currentDashboard = currentDashboard - 1
        }
        updateDashboard()
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
                // Customize Statusbar Look
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
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        refreshTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateDashboard), userInfo: nil, repeats: true)
    }

    @objc func updateDashboard(){
        if (currentDashboard == 1){
            DispatchQueue.global(qos: .userInitiated).async {
               // Do long running task here
                let xml = StandardDashboard.updateDashboard(self.currentInfoLine)
               // Bounce back to the main thread to update the UI
               DispatchQueue.main.async {
                   self.webView.loadHTMLString(xml.description, baseURL: nil)
               }
            }
        } else if (currentDashboard == 2){
            DispatchQueue.global(qos: .userInitiated).async {
               // Do long running task here
                let xml = SportDashboard.updateDashboard(self.currentInfoLine)
               // Bounce back to the main thread to update the UI
               DispatchQueue.main.async {
                   self.webView.loadHTMLString(xml.description, baseURL: nil)
               }
            }
        } else if (currentDashboard == 3){
            DispatchQueue.global(qos: .userInitiated).async {
               // Do long running task here
                let xml = ADVDashboard.updateDashboard(self.currentInfoLine)
               // Bounce back to the main thread to update the UI
               DispatchQueue.main.async {
                   self.webView.loadHTMLString(xml.description, baseURL: nil)
               }
            }
        }
    }

    @objc func launchAccPage(){
        if self.viewIfLoaded?.window != nil {
            let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "AccessoryViewController") as! AccessoryViewController
            self.navigationController!.pushViewController(secondViewController, animated: true)
        }
    }
}
