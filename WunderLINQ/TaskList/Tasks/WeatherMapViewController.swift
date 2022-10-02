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

class WeatherMapViewController: UIViewController {
    
    let motorcycleData = MotorcycleData.shared
    
    var currentZoom = 10
    
    let marker = GMSMarker()
    
    var refreshTimer = Timer()

    @IBOutlet weak var mapView: GMSMapView!
    
    // Implement GMSTileURLConstructor
    // Returns a Tile based on the x,y, and zoom coordinates
    let urls: GMSTileURLConstructor = {(x, y, zoom) in
        var unixtime: CLong = CLong(Date().timeIntervalSince1970)
        var timestamp = unixtime - ( unixtime % (10*60))
        let url = "https://tilecache.rainviewer.com/v2/radar/\(timestamp)/256/\(zoom)/\(x)/\(y)/4/1_1.png"
        return URL(string: url)
    }
    
    override var keyCommands: [UIKeyCommand]? {
        
        let commands = [
            UIKeyCommand(input: "\u{d}", modifierFlags:[], action: #selector(centerMap), discoverabilityTitle: "Select item"),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags:[], action: #selector(zoomIn), discoverabilityTitle: "Go up"),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags:[], action: #selector(zoomOut), discoverabilityTitle: "Go down"),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags:[], action: #selector(leftScreen), discoverabilityTitle: "Go left")
        ]
        return commands
    }
    
    @objc func centerMap() {
        if let lat = motorcycleData.location?.coordinate.latitude, let lon = motorcycleData.location?.coordinate.longitude{
            let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 10.0)
            mapView.camera = camera
            mapView?.animate(to: camera)
        }
    }
    
    @objc func zoomIn() {
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
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
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
        self.navigationItem.title = NSLocalizedString("weathermap_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton]
        
        mapView.clear()
        
        if let lat = motorcycleData.location?.coordinate.latitude, let lon = motorcycleData.location?.coordinate.longitude{
            let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 10.0)
            mapView.camera = camera
            mapView.mapType = .normal
            // Create the GMSTileLayer
            let layer = GMSURLTileLayer(urlConstructor: urls)
            
            // Display on the map at a specific zIndex
            layer.zIndex = 100
            //layer.opacity = 0.5
            layer.map = mapView
            // Creates a marker in the center of the map.
            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            marker.map = mapView
            
            startRefreshTimer()
        } else {
            print("Invalid Value")
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startRefreshTimer(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        refreshTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.refreshMap), userInfo: nil, repeats: true)
    }
    
    @objc func refreshMap(){
        print("refreshMap()")
        if let lat = motorcycleData.location?.coordinate.latitude, let lon = motorcycleData.location?.coordinate.longitude{
            mapView.clear()
            let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 10.0)
            mapView.camera = camera
            mapView.mapType = .normal
            // Create the GMSTileLayer
            let layer = GMSURLTileLayer(urlConstructor: urls)
            
            // Display on the map at a specific zIndex
            layer.zIndex = 100
            //layer.opacity = 0.5
            layer.map = mapView
            // Creates a marker in the center of the map.
            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            marker.map = mapView
        } else {
            print("Invalid Value")
        }
    }
}
