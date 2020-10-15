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
    
    let motorcycleData = MotorcycleData.shared
    let faults = Faults.shared
    
    var webView:UIWebView = UIWebView()
    
    var timer = Timer()
    var refreshTimer = Timer()
    var seconds = 10
    var isTimerRunning = false
    
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
        dashView.addSubview(webView)
        
        updateDashboard()

        scheduledTimerWithTimeInterval()
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
    override func viewWillAppear(_ animated: Bool) {
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
        refreshTimer.invalidate()
        seconds = 0
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
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
        self.navigationController?.setNavigationBarHidden(false, animated: true)
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
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags:[], action: #selector(leftScreen), discoverabilityTitle: "Go left"),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags:[], action: #selector(rightScreen), discoverabilityTitle: "Go right"),
        ]
        return commands
    }
    
    @objc func leftScreen() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func rightScreen() {
        performSegue(withIdentifier: "dashToMusic", sender: [])
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
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            seconds -= 1
        }
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        refreshTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateDashboard), userInfo: nil, repeats: true)
    }

    @objc func updateDashboard(){

        var temperatureUnit = "C"
        var distanceUnit = "km"
        var distanceTimeUnit = "KMH"
        var pressureUnit = "psi"
        
        guard let url = Bundle.main.url(forResource: "gstft-dashboard", withExtension: "svg") else { return }
        guard let xml = XML(contentsOf: url) else { return }

        //Speed
        if motorcycleData.speed != nil {
            var speedValue = motorcycleData.speed!
            if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                speedValue = Utility.kmToMiles(speedValue)
            }
            xml[0][4][11][0]["tspan"]?.text = "\(Int(round(speedValue)))"
        }
        if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
            distanceTimeUnit = "MPH"
        }
        xml[0][4][10][1]["text"]?["tspan"]?.text = distanceTimeUnit
        
        //Gear
        var gearValue = "-"
        if motorcycleData.gear != nil {
            gearValue = motorcycleData.getgear()
            if gearValue == "N"{
                guard let style = xml[0][4][11][1]["tspan"]?.attributes["style"] else {return}
                let regex = try! NSRegularExpression(pattern: "fill:([^<]*);", options: NSRegularExpression.Options.caseInsensitive)
                let range = NSMakeRange(0, style.count)
                let modString = regex.stringByReplacingMatches(in: style, options: [], range: range, withTemplate: "fill:#03ae1e;")
                xml[0][4][11][1]["tspan"]?.attributes["style"] = modString
            }
        }
        xml[0][4][11][1]["tspan"]?.text = gearValue
        
        // Ambient Temperature
        var ambientTempValue = "-"
        if motorcycleData.ambientTemperature != nil {
            var ambientTemp:Double = motorcycleData.ambientTemperature!
            if(ambientTemp <= 0){
                //icon = (UIImage(named: "Snowflake")?.withRenderingMode(.alwaysTemplate))!
            }
            if UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 {
                temperatureUnit = "F"
                ambientTemp = Utility.celciusToFahrenheit(ambientTemp)
            }
            ambientTempValue = "\(Int(round(ambientTemp)))\(temperatureUnit)"
        }
        xml[0][4][11][2]["tspan"]?.text = ambientTempValue
        
        // Engine Temperature
        var engineTempValue = "-"
        if motorcycleData.engineTemperature != nil {
            var engineTemp:Double = motorcycleData.engineTemperature!
            if (engineTemp >= 104.0){
                guard let style = xml[0][4][11][3]["tspan"]?.attributes["style"] else {return}
                let regex = try! NSRegularExpression(pattern: "fill:([^<]*);", options: NSRegularExpression.Options.caseInsensitive)
                let range = NSMakeRange(0, style.count)
                let modString = regex.stringByReplacingMatches(in: style, options: [], range: range, withTemplate: "fill:#e20505;")
                xml[0][4][11][3]["tspan"]?.attributes["style"] = modString
            }
            if (UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 ){
                temperatureUnit = "F"
                engineTemp = Utility.celciusToFahrenheit(engineTemp)
            }
            engineTempValue = "\(Int(round(engineTemp)))\(temperatureUnit)"
        }
        xml[0][4][11][3]["tspan"]?.text = engineTempValue
        
        //Fuel Range
        var fuelRangeValue = "-"
        if motorcycleData.fuelRange != nil {
            var fuelRange:Double = motorcycleData.fuelRange!
            if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                distanceUnit = "mls"
                fuelRange = Utility.kmToMiles(fuelRange)
            }
            fuelRangeValue = "\(Int(round(fuelRange)))\(distanceUnit)"
        }
        xml[0][4][11][4]["tspan"]?.text = fuelRangeValue
        if(faults.getFuelFaultActive()){
            guard let style = xml[0][4][11][4]["tspan"]?.attributes["style"] else {return}
            let regex = try! NSRegularExpression(pattern: "fill:([^<]*);", options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, style.count)
            let modString = regex.stringByReplacingMatches(in: style, options: [], range: range, withTemplate: "fill:#e20505;")
            xml[0][4][11][4]["tspan"]?.attributes["style"] = modString
            //Fuel Icon
            xml[0][4][12][3].attributes["style"] = "display:inline"
        }
        
        //Time
        var timeValue = ":"
        if motorcycleData.time != nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm"
            if UserDefaults.standard.integer(forKey: "time_format_preference") > 0 {
                formatter.dateFormat = "HH:mm"
            }
            timeValue = ("\(formatter.string(from: motorcycleData.time!))")
        }
        xml[0][4][11][5]["tspan"]?.text = timeValue
        
        // Front Tire Pressure
        var rdcFValue = "-"
        if motorcycleData.frontTirePressure != nil {
            var frontPressure:Double = motorcycleData.frontTirePressure!
            switch UserDefaults.standard.integer(forKey: "pressure_unit_preference"){
            case 1:
                pressureUnit = "kPa"
                frontPressure = Utility.barTokPa(frontPressure)
            case 2:
                pressureUnit = "kgf"
                frontPressure = Utility.barTokgf(frontPressure)
            case 3:
                pressureUnit = "psi"
                frontPressure = Utility.barToPsi(frontPressure)
            default:
                pressureUnit = "bar"
                break
            }
            rdcFValue = "\(frontPressure.rounded(toPlaces: 1))\(pressureUnit)"
        }
        xml[0][4][11][6]["tspan"]?.text = rdcFValue
        
        if(faults.getFrontTirePressureCriticalActive()){
            guard let style = xml[0][4][11][6]["tspan"]?.attributes["style"] else {return}
            let regex = try! NSRegularExpression(pattern: "fill:([^<]*);", options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, style.count)
            let modString = regex.stringByReplacingMatches(in: style, options: [], range: range, withTemplate: "fill:#e20505;")
            xml[0][4][11][6]["tspan"]?.attributes["style"] = modString
        } else if(faults.getRearTirePressureWarningActive()){
            guard let style = xml[0][4][11][6]["tspan"]?.attributes["style"] else {return}
            let regex = try! NSRegularExpression(pattern: "fill:([^<]*);", options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, style.count)
            let modString = regex.stringByReplacingMatches(in: style, options: [], range: range, withTemplate: "fill:#fcc914;")
            xml[0][4][11][6]["tspan"]?.attributes["style"] = modString
        }
        
        // Rear Tire Pressure
        var rdcRValue = "-"
        if motorcycleData.rearTirePressure != nil {
            var rearPressure:Double = motorcycleData.rearTirePressure!
            switch UserDefaults.standard.integer(forKey: "pressure_unit_preference"){
            case 1:
                pressureUnit = "kPa"
                rearPressure = Utility.barTokPa(rearPressure)
            case 2:
                pressureUnit = "kgf"
                rearPressure = Utility.barTokgf(rearPressure)
            case 3:
                pressureUnit = "psi"
                rearPressure = Utility.barToPsi(rearPressure)
            default:
                pressureUnit = "bar"
                break
            }
            rdcRValue = "\(rearPressure.rounded(toPlaces: 1))\(pressureUnit)"
        }
        xml[0][4][11][7]["tspan"]?.text = rdcRValue
        
        if(faults.getRearTirePressureCriticalActive()){
            guard let style = xml[0][4][11][7]["tspan"]?.attributes["style"] else {return}
            let regex = try! NSRegularExpression(pattern: "fill:([^<]*);", options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, style.count)
            let modString = regex.stringByReplacingMatches(in: style, options: [], range: range, withTemplate: "fill:#e20505;")
            xml[0][4][11][7]["tspan"]?.attributes["style"] = modString
        } else if(faults.getRearTirePressureWarningActive()){
            guard let style = xml[0][4][11][7]["tspan"]?.attributes["style"] else {return}
            let regex = try! NSRegularExpression(pattern: "fill:([^<]*);", options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, style.count)
            let modString = regex.stringByReplacingMatches(in: style, options: [], range: range, withTemplate: "fill:#fcc914;")
            xml[0][4][11][7]["tspan"]?.attributes["style"] = modString
        }
        
        //Trip Logging
        //xml[0][5][0].attributes["style"] = "display:inline"
        //Camera
        //xml[0][5][1].attributes["style"] = "display:inline"
        
        // Fault icon
        if(!faults.getallActiveDesc().isEmpty){
            xml[0][4][12][2].attributes["style"] = "display:inline"
        }
        
        // RPM Tiles
        if motorcycleData.rpm != nil {
            switch (motorcycleData.getRPM()){
            case 1..<334:
                xml[0][4][13][1].attributes["style"] = "display:inline"
            case 334..<667:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
            case 667..<1001:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
            case 1001..<1334:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
                xml[0][4][13][4].attributes["style"] = "display:inline"
            case 1334..<1667:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
                xml[0][4][13][4].attributes["style"] = "display:inline"
                xml[0][4][13][5].attributes["style"] = "display:inline"
            case 1667..<2001:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
                xml[0][4][13][4].attributes["style"] = "display:inline"
                xml[0][4][13][5].attributes["style"] = "display:inline"
                xml[0][4][13][6].attributes["style"] = "display:inline"
            case 2001..<2334:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
                xml[0][4][13][4].attributes["style"] = "display:inline"
                xml[0][4][13][5].attributes["style"] = "display:inline"
                xml[0][4][13][6].attributes["style"] = "display:inline"
                xml[0][4][13][7].attributes["style"] = "display:inline"
            case 2334..<2667:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
                xml[0][4][13][4].attributes["style"] = "display:inline"
                xml[0][4][13][5].attributes["style"] = "display:inline"
                xml[0][4][13][6].attributes["style"] = "display:inline"
                xml[0][4][13][7].attributes["style"] = "display:inline"
                xml[0][4][13][8].attributes["style"] = "display:inline"
            case 2667..<3001:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
                xml[0][4][13][4].attributes["style"] = "display:inline"
                xml[0][4][13][5].attributes["style"] = "display:inline"
                xml[0][4][13][6].attributes["style"] = "display:inline"
                xml[0][4][13][7].attributes["style"] = "display:inline"
                xml[0][4][13][8].attributes["style"] = "display:inline"
                xml[0][4][13][9].attributes["style"] = "display:inline"
            case 3001..<3334:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
                xml[0][4][13][4].attributes["style"] = "display:inline"
                xml[0][4][13][5].attributes["style"] = "display:inline"
                xml[0][4][13][6].attributes["style"] = "display:inline"
                xml[0][4][13][7].attributes["style"] = "display:inline"
                xml[0][4][13][8].attributes["style"] = "display:inline"
                xml[0][4][13][9].attributes["style"] = "display:inline"
                xml[0][4][13][10].attributes["style"] = "display:inline"
            case 3334..<3667:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
                xml[0][4][13][4].attributes["style"] = "display:inline"
                xml[0][4][13][5].attributes["style"] = "display:inline"
                xml[0][4][13][6].attributes["style"] = "display:inline"
                xml[0][4][13][7].attributes["style"] = "display:inline"
                xml[0][4][13][8].attributes["style"] = "display:inline"
                xml[0][4][13][9].attributes["style"] = "display:inline"
                xml[0][4][13][10].attributes["style"] = "display:inline"
                xml[0][4][13][11].attributes["style"] = "display:inline"
            case 3667..<4001:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
                xml[0][4][13][4].attributes["style"] = "display:inline"
                xml[0][4][13][5].attributes["style"] = "display:inline"
                xml[0][4][13][6].attributes["style"] = "display:inline"
                xml[0][4][13][7].attributes["style"] = "display:inline"
                xml[0][4][13][8].attributes["style"] = "display:inline"
                xml[0][4][13][9].attributes["style"] = "display:inline"
                xml[0][4][13][10].attributes["style"] = "display:inline"
                xml[0][4][13][11].attributes["style"] = "display:inline"
                xml[0][4][13][12].attributes["style"] = "display:inline"
            case 4001..<4334:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
                xml[0][4][13][4].attributes["style"] = "display:inline"
                xml[0][4][13][5].attributes["style"] = "display:inline"
                xml[0][4][13][6].attributes["style"] = "display:inline"
                xml[0][4][13][7].attributes["style"] = "display:inline"
                xml[0][4][13][8].attributes["style"] = "display:inline"
                xml[0][4][13][9].attributes["style"] = "display:inline"
                xml[0][4][13][10].attributes["style"] = "display:inline"
                xml[0][4][13][11].attributes["style"] = "display:inline"
                xml[0][4][13][12].attributes["style"] = "display:inline"
                xml[0][4][13][13].attributes["style"] = "display:inline"
            case 4334..<4667:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
                xml[0][4][13][4].attributes["style"] = "display:inline"
                xml[0][4][13][5].attributes["style"] = "display:inline"
                xml[0][4][13][6].attributes["style"] = "display:inline"
                xml[0][4][13][7].attributes["style"] = "display:inline"
                xml[0][4][13][8].attributes["style"] = "display:inline"
                xml[0][4][13][9].attributes["style"] = "display:inline"
                xml[0][4][13][10].attributes["style"] = "display:inline"
                xml[0][4][13][11].attributes["style"] = "display:inline"
                xml[0][4][13][12].attributes["style"] = "display:inline"
                xml[0][4][13][13].attributes["style"] = "display:inline"
                xml[0][4][13][14].attributes["style"] = "display:inline"
            case 4667..<5001:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
                xml[0][4][13][4].attributes["style"] = "display:inline"
                xml[0][4][13][5].attributes["style"] = "display:inline"
                xml[0][4][13][6].attributes["style"] = "display:inline"
                xml[0][4][13][7].attributes["style"] = "display:inline"
                xml[0][4][13][8].attributes["style"] = "display:inline"
                xml[0][4][13][9].attributes["style"] = "display:inline"
                xml[0][4][13][10].attributes["style"] = "display:inline"
                xml[0][4][13][11].attributes["style"] = "display:inline"
                xml[0][4][13][12].attributes["style"] = "display:inline"
                xml[0][4][13][13].attributes["style"] = "display:inline"
                xml[0][4][13][14].attributes["style"] = "display:inline"
                xml[0][4][13][15].attributes["style"] = "display:inline"
            case 5001..<5334:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
                xml[0][4][13][4].attributes["style"] = "display:inline"
                xml[0][4][13][5].attributes["style"] = "display:inline"
                xml[0][4][13][6].attributes["style"] = "display:inline"
                xml[0][4][13][7].attributes["style"] = "display:inline"
                xml[0][4][13][8].attributes["style"] = "display:inline"
                xml[0][4][13][9].attributes["style"] = "display:inline"
                xml[0][4][13][10].attributes["style"] = "display:inline"
                xml[0][4][13][11].attributes["style"] = "display:inline"
                xml[0][4][13][12].attributes["style"] = "display:inline"
                xml[0][4][13][13].attributes["style"] = "display:inline"
                xml[0][4][13][14].attributes["style"] = "display:inline"
                xml[0][4][13][15].attributes["style"] = "display:inline"
                xml[0][4][13][16].attributes["style"] = "display:inline"
            case 5334..<5667:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
                xml[0][4][13][4].attributes["style"] = "display:inline"
                xml[0][4][13][5].attributes["style"] = "display:inline"
                xml[0][4][13][6].attributes["style"] = "display:inline"
                xml[0][4][13][7].attributes["style"] = "display:inline"
                xml[0][4][13][8].attributes["style"] = "display:inline"
                xml[0][4][13][9].attributes["style"] = "display:inline"
                xml[0][4][13][10].attributes["style"] = "display:inline"
                xml[0][4][13][11].attributes["style"] = "display:inline"
                xml[0][4][13][12].attributes["style"] = "display:inline"
                xml[0][4][13][13].attributes["style"] = "display:inline"
                xml[0][4][13][14].attributes["style"] = "display:inline"
                xml[0][4][13][15].attributes["style"] = "display:inline"
                xml[0][4][13][16].attributes["style"] = "display:inline"
                xml[0][4][13][17].attributes["style"] = "display:inline"
            case 5667..<6001:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
                xml[0][4][13][4].attributes["style"] = "display:inline"
                xml[0][4][13][5].attributes["style"] = "display:inline"
                xml[0][4][13][6].attributes["style"] = "display:inline"
                xml[0][4][13][7].attributes["style"] = "display:inline"
                xml[0][4][13][8].attributes["style"] = "display:inline"
                xml[0][4][13][9].attributes["style"] = "display:inline"
                xml[0][4][13][10].attributes["style"] = "display:inline"
                xml[0][4][13][11].attributes["style"] = "display:inline"
                xml[0][4][13][12].attributes["style"] = "display:inline"
                xml[0][4][13][13].attributes["style"] = "display:inline"
                xml[0][4][13][14].attributes["style"] = "display:inline"
                xml[0][4][13][15].attributes["style"] = "display:inline"
                xml[0][4][13][16].attributes["style"] = "display:inline"
                xml[0][4][13][17].attributes["style"] = "display:inline"
                xml[0][4][13][18].attributes["style"] = "display:inline"
            case 6001..<6334:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
                xml[0][4][13][4].attributes["style"] = "display:inline"
                xml[0][4][13][5].attributes["style"] = "display:inline"
                xml[0][4][13][6].attributes["style"] = "display:inline"
                xml[0][4][13][7].attributes["style"] = "display:inline"
                xml[0][4][13][8].attributes["style"] = "display:inline"
                xml[0][4][13][9].attributes["style"] = "display:inline"
                xml[0][4][13][10].attributes["style"] = "display:inline"
                xml[0][4][13][11].attributes["style"] = "display:inline"
                xml[0][4][13][12].attributes["style"] = "display:inline"
                xml[0][4][13][13].attributes["style"] = "display:inline"
                xml[0][4][13][14].attributes["style"] = "display:inline"
                xml[0][4][13][15].attributes["style"] = "display:inline"
                xml[0][4][13][16].attributes["style"] = "display:inline"
                xml[0][4][13][17].attributes["style"] = "display:inline"
                xml[0][4][13][18].attributes["style"] = "display:inline"
                xml[0][4][13][19].attributes["style"] = "display:inline"
            case 6334..<6667:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
                xml[0][4][13][4].attributes["style"] = "display:inline"
                xml[0][4][13][5].attributes["style"] = "display:inline"
                xml[0][4][13][6].attributes["style"] = "display:inline"
                xml[0][4][13][7].attributes["style"] = "display:inline"
                xml[0][4][13][8].attributes["style"] = "display:inline"
                xml[0][4][13][9].attributes["style"] = "display:inline"
                xml[0][4][13][10].attributes["style"] = "display:inline"
                xml[0][4][13][11].attributes["style"] = "display:inline"
                xml[0][4][13][12].attributes["style"] = "display:inline"
                xml[0][4][13][13].attributes["style"] = "display:inline"
                xml[0][4][13][14].attributes["style"] = "display:inline"
                xml[0][4][13][15].attributes["style"] = "display:inline"
                xml[0][4][13][16].attributes["style"] = "display:inline"
                xml[0][4][13][17].attributes["style"] = "display:inline"
                xml[0][4][13][18].attributes["style"] = "display:inline"
                xml[0][4][13][19].attributes["style"] = "display:inline"
                xml[0][4][13][20].attributes["style"] = "display:inline"
            case 6667..<7001:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
                xml[0][4][13][4].attributes["style"] = "display:inline"
                xml[0][4][13][5].attributes["style"] = "display:inline"
                xml[0][4][13][6].attributes["style"] = "display:inline"
                xml[0][4][13][7].attributes["style"] = "display:inline"
                xml[0][4][13][8].attributes["style"] = "display:inline"
                xml[0][4][13][9].attributes["style"] = "display:inline"
                xml[0][4][13][10].attributes["style"] = "display:inline"
                xml[0][4][13][11].attributes["style"] = "display:inline"
                xml[0][4][13][12].attributes["style"] = "display:inline"
                xml[0][4][13][13].attributes["style"] = "display:inline"
                xml[0][4][13][14].attributes["style"] = "display:inline"
                xml[0][4][13][15].attributes["style"] = "display:inline"
                xml[0][4][13][16].attributes["style"] = "display:inline"
                xml[0][4][13][17].attributes["style"] = "display:inline"
                xml[0][4][13][18].attributes["style"] = "display:inline"
                xml[0][4][13][19].attributes["style"] = "display:inline"
                xml[0][4][13][20].attributes["style"] = "display:inline"
                xml[0][4][13][21].attributes["style"] = "display:inline"
            case 7001..<7334:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
                xml[0][4][13][4].attributes["style"] = "display:inline"
                xml[0][4][13][5].attributes["style"] = "display:inline"
                xml[0][4][13][6].attributes["style"] = "display:inline"
                xml[0][4][13][7].attributes["style"] = "display:inline"
                xml[0][4][13][8].attributes["style"] = "display:inline"
                xml[0][4][13][9].attributes["style"] = "display:inline"
                xml[0][4][13][10].attributes["style"] = "display:inline"
                xml[0][4][13][11].attributes["style"] = "display:inline"
                xml[0][4][13][12].attributes["style"] = "display:inline"
                xml[0][4][13][13].attributes["style"] = "display:inline"
                xml[0][4][13][14].attributes["style"] = "display:inline"
                xml[0][4][13][15].attributes["style"] = "display:inline"
                xml[0][4][13][16].attributes["style"] = "display:inline"
                xml[0][4][13][17].attributes["style"] = "display:inline"
                xml[0][4][13][18].attributes["style"] = "display:inline"
                xml[0][4][13][19].attributes["style"] = "display:inline"
                xml[0][4][13][20].attributes["style"] = "display:inline"
                xml[0][4][13][21].attributes["style"] = "display:inline"
                xml[0][4][13][22].attributes["style"] = "display:inline"
            case 7334..<7667:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
                xml[0][4][13][4].attributes["style"] = "display:inline"
                xml[0][4][13][5].attributes["style"] = "display:inline"
                xml[0][4][13][6].attributes["style"] = "display:inline"
                xml[0][4][13][7].attributes["style"] = "display:inline"
                xml[0][4][13][8].attributes["style"] = "display:inline"
                xml[0][4][13][9].attributes["style"] = "display:inline"
                xml[0][4][13][10].attributes["style"] = "display:inline"
                xml[0][4][13][11].attributes["style"] = "display:inline"
                xml[0][4][13][12].attributes["style"] = "display:inline"
                xml[0][4][13][13].attributes["style"] = "display:inline"
                xml[0][4][13][14].attributes["style"] = "display:inline"
                xml[0][4][13][15].attributes["style"] = "display:inline"
                xml[0][4][13][16].attributes["style"] = "display:inline"
                xml[0][4][13][17].attributes["style"] = "display:inline"
                xml[0][4][13][18].attributes["style"] = "display:inline"
                xml[0][4][13][19].attributes["style"] = "display:inline"
                xml[0][4][13][20].attributes["style"] = "display:inline"
                xml[0][4][13][21].attributes["style"] = "display:inline"
                xml[0][4][13][22].attributes["style"] = "display:inline"
                xml[0][4][13][23].attributes["style"] = "display:inline"
            case 7667..<8001:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
                xml[0][4][13][4].attributes["style"] = "display:inline"
                xml[0][4][13][5].attributes["style"] = "display:inline"
                xml[0][4][13][6].attributes["style"] = "display:inline"
                xml[0][4][13][7].attributes["style"] = "display:inline"
                xml[0][4][13][8].attributes["style"] = "display:inline"
                xml[0][4][13][9].attributes["style"] = "display:inline"
                xml[0][4][13][10].attributes["style"] = "display:inline"
                xml[0][4][13][11].attributes["style"] = "display:inline"
                xml[0][4][13][12].attributes["style"] = "display:inline"
                xml[0][4][13][13].attributes["style"] = "display:inline"
                xml[0][4][13][14].attributes["style"] = "display:inline"
                xml[0][4][13][15].attributes["style"] = "display:inline"
                xml[0][4][13][16].attributes["style"] = "display:inline"
                xml[0][4][13][17].attributes["style"] = "display:inline"
                xml[0][4][13][18].attributes["style"] = "display:inline"
                xml[0][4][13][19].attributes["style"] = "display:inline"
                xml[0][4][13][20].attributes["style"] = "display:inline"
                xml[0][4][13][21].attributes["style"] = "display:inline"
                xml[0][4][13][22].attributes["style"] = "display:inline"
                xml[0][4][13][23].attributes["style"] = "display:inline"
                xml[0][4][13][24].attributes["style"] = "display:inline"
            case 8001..<8334:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
                xml[0][4][13][4].attributes["style"] = "display:inline"
                xml[0][4][13][5].attributes["style"] = "display:inline"
                xml[0][4][13][6].attributes["style"] = "display:inline"
                xml[0][4][13][7].attributes["style"] = "display:inline"
                xml[0][4][13][8].attributes["style"] = "display:inline"
                xml[0][4][13][9].attributes["style"] = "display:inline"
                xml[0][4][13][10].attributes["style"] = "display:inline"
                xml[0][4][13][11].attributes["style"] = "display:inline"
                xml[0][4][13][12].attributes["style"] = "display:inline"
                xml[0][4][13][13].attributes["style"] = "display:inline"
                xml[0][4][13][14].attributes["style"] = "display:inline"
                xml[0][4][13][15].attributes["style"] = "display:inline"
                xml[0][4][13][16].attributes["style"] = "display:inline"
                xml[0][4][13][17].attributes["style"] = "display:inline"
                xml[0][4][13][18].attributes["style"] = "display:inline"
                xml[0][4][13][19].attributes["style"] = "display:inline"
                xml[0][4][13][20].attributes["style"] = "display:inline"
                xml[0][4][13][21].attributes["style"] = "display:inline"
                xml[0][4][13][22].attributes["style"] = "display:inline"
                xml[0][4][13][23].attributes["style"] = "display:inline"
                xml[0][4][13][24].attributes["style"] = "display:inline"
                xml[0][4][13][25].attributes["style"] = "display:inline"
            case 8334..<8667:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
                xml[0][4][13][4].attributes["style"] = "display:inline"
                xml[0][4][13][5].attributes["style"] = "display:inline"
                xml[0][4][13][6].attributes["style"] = "display:inline"
                xml[0][4][13][7].attributes["style"] = "display:inline"
                xml[0][4][13][8].attributes["style"] = "display:inline"
                xml[0][4][13][9].attributes["style"] = "display:inline"
                xml[0][4][13][10].attributes["style"] = "display:inline"
                xml[0][4][13][11].attributes["style"] = "display:inline"
                xml[0][4][13][12].attributes["style"] = "display:inline"
                xml[0][4][13][13].attributes["style"] = "display:inline"
                xml[0][4][13][14].attributes["style"] = "display:inline"
                xml[0][4][13][15].attributes["style"] = "display:inline"
                xml[0][4][13][16].attributes["style"] = "display:inline"
                xml[0][4][13][17].attributes["style"] = "display:inline"
                xml[0][4][13][18].attributes["style"] = "display:inline"
                xml[0][4][13][19].attributes["style"] = "display:inline"
                xml[0][4][13][20].attributes["style"] = "display:inline"
                xml[0][4][13][21].attributes["style"] = "display:inline"
                xml[0][4][13][22].attributes["style"] = "display:inline"
                xml[0][4][13][23].attributes["style"] = "display:inline"
                xml[0][4][13][24].attributes["style"] = "display:inline"
                xml[0][4][13][25].attributes["style"] = "display:inline"
                xml[0][4][13][26].attributes["style"] = "display:inline"
            case 8667..<9001:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
                xml[0][4][13][4].attributes["style"] = "display:inline"
                xml[0][4][13][5].attributes["style"] = "display:inline"
                xml[0][4][13][6].attributes["style"] = "display:inline"
                xml[0][4][13][7].attributes["style"] = "display:inline"
                xml[0][4][13][8].attributes["style"] = "display:inline"
                xml[0][4][13][9].attributes["style"] = "display:inline"
                xml[0][4][13][10].attributes["style"] = "display:inline"
                xml[0][4][13][11].attributes["style"] = "display:inline"
                xml[0][4][13][12].attributes["style"] = "display:inline"
                xml[0][4][13][13].attributes["style"] = "display:inline"
                xml[0][4][13][14].attributes["style"] = "display:inline"
                xml[0][4][13][15].attributes["style"] = "display:inline"
                xml[0][4][13][16].attributes["style"] = "display:inline"
                xml[0][4][13][17].attributes["style"] = "display:inline"
                xml[0][4][13][18].attributes["style"] = "display:inline"
                xml[0][4][13][19].attributes["style"] = "display:inline"
                xml[0][4][13][20].attributes["style"] = "display:inline"
                xml[0][4][13][21].attributes["style"] = "display:inline"
                xml[0][4][13][22].attributes["style"] = "display:inline"
                xml[0][4][13][23].attributes["style"] = "display:inline"
                xml[0][4][13][24].attributes["style"] = "display:inline"
                xml[0][4][13][25].attributes["style"] = "display:inline"
                xml[0][4][13][26].attributes["style"] = "display:inline"
                xml[0][4][13][27].attributes["style"] = "display:inline"
            case 9001..<9334:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
                xml[0][4][13][4].attributes["style"] = "display:inline"
                xml[0][4][13][5].attributes["style"] = "display:inline"
                xml[0][4][13][6].attributes["style"] = "display:inline"
                xml[0][4][13][7].attributes["style"] = "display:inline"
                xml[0][4][13][8].attributes["style"] = "display:inline"
                xml[0][4][13][9].attributes["style"] = "display:inline"
                xml[0][4][13][10].attributes["style"] = "display:inline"
                xml[0][4][13][11].attributes["style"] = "display:inline"
                xml[0][4][13][12].attributes["style"] = "display:inline"
                xml[0][4][13][13].attributes["style"] = "display:inline"
                xml[0][4][13][14].attributes["style"] = "display:inline"
                xml[0][4][13][15].attributes["style"] = "display:inline"
                xml[0][4][13][16].attributes["style"] = "display:inline"
                xml[0][4][13][17].attributes["style"] = "display:inline"
                xml[0][4][13][18].attributes["style"] = "display:inline"
                xml[0][4][13][19].attributes["style"] = "display:inline"
                xml[0][4][13][20].attributes["style"] = "display:inline"
                xml[0][4][13][21].attributes["style"] = "display:inline"
                xml[0][4][13][22].attributes["style"] = "display:inline"
                xml[0][4][13][23].attributes["style"] = "display:inline"
                xml[0][4][13][24].attributes["style"] = "display:inline"
                xml[0][4][13][25].attributes["style"] = "display:inline"
                xml[0][4][13][26].attributes["style"] = "display:inline"
                xml[0][4][13][27].attributes["style"] = "display:inline"
                xml[0][4][13][28].attributes["style"] = "display:inline"
            case 9334..<9667:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
                xml[0][4][13][4].attributes["style"] = "display:inline"
                xml[0][4][13][5].attributes["style"] = "display:inline"
                xml[0][4][13][6].attributes["style"] = "display:inline"
                xml[0][4][13][7].attributes["style"] = "display:inline"
                xml[0][4][13][8].attributes["style"] = "display:inline"
                xml[0][4][13][9].attributes["style"] = "display:inline"
                xml[0][4][13][10].attributes["style"] = "display:inline"
                xml[0][4][13][11].attributes["style"] = "display:inline"
                xml[0][4][13][12].attributes["style"] = "display:inline"
                xml[0][4][13][13].attributes["style"] = "display:inline"
                xml[0][4][13][14].attributes["style"] = "display:inline"
                xml[0][4][13][15].attributes["style"] = "display:inline"
                xml[0][4][13][16].attributes["style"] = "display:inline"
                xml[0][4][13][17].attributes["style"] = "display:inline"
                xml[0][4][13][18].attributes["style"] = "display:inline"
                xml[0][4][13][19].attributes["style"] = "display:inline"
                xml[0][4][13][20].attributes["style"] = "display:inline"
                xml[0][4][13][21].attributes["style"] = "display:inline"
                xml[0][4][13][22].attributes["style"] = "display:inline"
                xml[0][4][13][23].attributes["style"] = "display:inline"
                xml[0][4][13][24].attributes["style"] = "display:inline"
                xml[0][4][13][25].attributes["style"] = "display:inline"
                xml[0][4][13][26].attributes["style"] = "display:inline"
                xml[0][4][13][27].attributes["style"] = "display:inline"
                xml[0][4][13][28].attributes["style"] = "display:inline"
                xml[0][4][13][29].attributes["style"] = "display:inline"
            case 9667..<10001:
                xml[0][4][13][1].attributes["style"] = "display:inline"
                xml[0][4][13][2].attributes["style"] = "display:inline"
                xml[0][4][13][3].attributes["style"] = "display:inline"
                xml[0][4][13][4].attributes["style"] = "display:inline"
                xml[0][4][13][5].attributes["style"] = "display:inline"
                xml[0][4][13][6].attributes["style"] = "display:inline"
                xml[0][4][13][7].attributes["style"] = "display:inline"
                xml[0][4][13][8].attributes["style"] = "display:inline"
                xml[0][4][13][9].attributes["style"] = "display:inline"
                xml[0][4][13][10].attributes["style"] = "display:inline"
                xml[0][4][13][11].attributes["style"] = "display:inline"
                xml[0][4][13][12].attributes["style"] = "display:inline"
                xml[0][4][13][13].attributes["style"] = "display:inline"
                xml[0][4][13][14].attributes["style"] = "display:inline"
                xml[0][4][13][15].attributes["style"] = "display:inline"
                xml[0][4][13][16].attributes["style"] = "display:inline"
                xml[0][4][13][17].attributes["style"] = "display:inline"
                xml[0][4][13][18].attributes["style"] = "display:inline"
                xml[0][4][13][19].attributes["style"] = "display:inline"
                xml[0][4][13][20].attributes["style"] = "display:inline"
                xml[0][4][13][21].attributes["style"] = "display:inline"
                xml[0][4][13][22].attributes["style"] = "display:inline"
                xml[0][4][13][23].attributes["style"] = "display:inline"
                xml[0][4][13][24].attributes["style"] = "display:inline"
                xml[0][4][13][25].attributes["style"] = "display:inline"
                xml[0][4][13][26].attributes["style"] = "display:inline"
                xml[0][4][13][27].attributes["style"] = "display:inline"
                xml[0][4][13][28].attributes["style"] = "display:inline"
                xml[0][4][13][29].attributes["style"] = "display:inline"
                xml[0][4][13][30].attributes["style"] = "display:inline"
            default:
                xml[0][4][13][0].attributes["style"] = "display:inline"
            }
        }
        
        webView.loadHTMLString(xml.description, baseURL: nil)
    }

}
