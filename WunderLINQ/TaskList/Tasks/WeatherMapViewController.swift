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
import SQLite3
import GoogleMaps
import MapKit
import os.log

class WeatherMapViewController: UIViewController {
    
    let motorcycleData = MotorcycleData.shared
    let faults = Faults.shared
    
    var currentZoom = 10
    
    let marker = GMSMarker()

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var faultsBtn: UIButton!
    var faultsButton: UIBarButtonItem!
    
    var displayLink: CADisplayLink?
    var startTime: CFTimeInterval?
    let animationDuration = 10.0 // Seconds
    var restartTimer: Timer?
    var lastTimestamp: Int?
    
    override var keyCommands: [UIKeyCommand]? {
        
        let commands = [
            UIKeyCommand(input: "\u{d}", modifierFlags:[], action: #selector(centerMap)),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags:[], action: #selector(zoomIn)),
            UIKeyCommand(input: "+", modifierFlags:[], action: #selector(zoomIn)),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags:[], action: #selector(zoomOut)),
            UIKeyCommand(input: "-", modifierFlags:[], action: #selector(zoomOut)),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags:[], action: #selector(leftScreen))
        ]
        if #available(iOS 15, *) {
            commands.forEach { $0.wantsPriorityOverSystemBehavior = true }
        }
        return commands
    }
    
    @objc func centerMap() {
        SoundManager().playSoundEffect("enter")
        if let lat = motorcycleData.location?.coordinate.latitude, let lon = motorcycleData.location?.coordinate.longitude{
            let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: Float(currentZoom))
            mapView.camera = camera
            mapView?.animate(to: camera)
        }
    }
    
    @objc func zoomIn() {
        SoundManager().playSoundEffect("directional")
        if (currentZoom < 16){
            currentZoom = currentZoom + 1
            if let lat = motorcycleData.location?.coordinate.latitude, let lon = motorcycleData.location?.coordinate.longitude{
                let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: Float(currentZoom))
                mapView.camera = camera
                mapView?.animate(to: camera)
            }
        }
    }
    
    @objc func zoomOut() {
        SoundManager().playSoundEffect("directional")
        if (currentZoom > 3){
            currentZoom = currentZoom - 1
            if let lat = motorcycleData.location?.coordinate.latitude, let lon = motorcycleData.location?.coordinate.longitude{
                let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: Float(currentZoom))
                mapView.camera = camera
                mapView?.animate(to: camera)
            }
        }
    }
    
    @objc func leftScreen() {
        SoundManager().playSoundEffect("directional")
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backBtn = UIButton()
        backBtn.setImage(UIImage(named: "Left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        backBtn.tintColor = UIColor(named: "imageTint")
        backBtn.addTarget(self, action: #selector(leftScreen), for: .touchUpInside)
        let backButton = UIBarButtonItem(customView: backBtn)
        let backButtonWidth = backButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        backButtonWidth?.isActive = true
        let backButtonHeight = backButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        backButtonHeight?.isActive = true
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
        self.navigationItem.title = NSLocalizedString("weathermap_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton, faultsButton]
        
        mapView.clear()
        
        startAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startAnimating() {
        os_log("WeatherMapViewController: startAnimating()")
        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
        displayLink?.add(to: .current, forMode: .default)
        startTime = CACurrentMediaTime()
        restartTimer = Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: false) { [weak self] timer in
            self?.restartAnimating()
        }
    }

    @objc func updateAnimation() {
        guard let startTime = startTime else { return }
        let elapsed = CACurrentMediaTime() - startTime
        let progress = elapsed / animationDuration
        let unixtime: CLong = CLong(calculateDateForProgress(progress).timeIntervalSince1970)
        let timestamp = unixtime - ( unixtime % (10*60))
        if (lastTimestamp != timestamp){
            lastTimestamp = timestamp
            configureMap(timestamp: timestamp)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss z yyyy"
            dateLabel.text = dateFormatter.string(from: calculateDateForProgress(progress))
            
            updateDisplay()
        }
    }
    
    func restartAnimating() {
        os_log("WeatherMapViewController: restartAnimating()")
        displayLink?.invalidate()
        displayLink = nil
        startTime = nil
        startAnimating()
    }

    func stopAnimating() {
        os_log("WeatherMapViewController: stopAnimating()")
        restartTimer?.invalidate()
        displayLink?.invalidate()
        displayLink = nil
        startTime = nil
    }
    
    private func calculateDateForProgress(_ progress: Double) -> Date {
        var cal = Calendar.current
        cal.timeZone = TimeZone.current
        let now = Date()
        
        // Calculate the timestamp for startime in the past
        let hoursInPast = 2
        let startTime = cal.date(byAdding: .hour, value: -hoursInPast, to: now)!

        // Calculate the timestamp for the current frame
        let timeRange: TimeInterval = 60 * 60 * Double(hoursInPast)
        let frameTime = timeRange * Double(progress)
        let frameDate = Date(timeInterval: frameTime, since: startTime)

        // Round down to the nearest 15-minute interval
        let minute = cal.component(.minute, from: frameDate)
        let roundedMinute = minute / 15 * 15
        var components = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: frameDate)
        components.nanosecond = 0
        // Set the minute component to the rounded value
        components.minute = roundedMinute

        return cal.date(from: components)!
    }

    private func configureMap(timestamp: Int) {
        if let lat = motorcycleData.location?.coordinate.latitude, let lon = motorcycleData.location?.coordinate.longitude{
            let url: GMSTileURLConstructor = {(x, y, zoom) in
                let urltemplate = "https://tilecache.rainviewer.com/v2/radar/\(timestamp)/256/\(zoom)/\(x)/\(y)/4/1_1.png"
                return URL(string: urltemplate)
            }
            mapView.clear()
            let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: Float(currentZoom))
            mapView.camera = camera
            mapView.mapType = .normal
            // Create the GMSTileLayer
            let layer = GMSURLTileLayer(urlConstructor: url)
            // Display on the map at a specific zIndex
            layer.zIndex = 100
            layer.map = mapView
            // Creates a marker in the center of the map.
            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            marker.map = mapView
        } else {
            os_log("WeatherMapViewController: Invalid Location")
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
    
    @objc func faultsButtonTapped() {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "FaultsTableViewController") as! FaultsTableViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
