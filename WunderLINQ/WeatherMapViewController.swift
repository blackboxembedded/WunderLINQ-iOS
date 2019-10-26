//
//  WeatherMapViewController.swift
//  WunderLINQ
//
//  Created by Keith Conger on 8/9/19.
//  Copyright © 2019 Black Box Embedded, LLC. All rights reserved.
//

import UIKit
import SQLite3
import GoogleMaps
import MapKit

class WeatherMapViewController: UIViewController {
    
    let motorcycleData = MotorcycleData.shared
    
    var currentZoom = 10

    @IBOutlet weak var mapView: GMSMapView!
    
    // Implement GMSTileURLConstructor
    // Returns a Tile based on the x,y, and zoom coordinates
    let urls: GMSTileURLConstructor = {(x, y, zoom) in
        //
        let url = "https://tile.openweathermap.org/map/precipitation/\(zoom)/\(x)/\(y).png?appid=538274f471a690b07f227bd744307f7d"
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppUtility.lockOrientation(.portrait)
        
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
            mapView.mapType = .hybrid
            // Create the GMSTileLayer
            let layer = GMSURLTileLayer(urlConstructor: urls)
            
            // Display on the map at a specific zIndex
            layer.zIndex = 100
            //layer.opacity = 0.5
            layer.map = mapView
            // Creates a marker in the center of the map.
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            marker.map = mapView
        } else {
            print("Invalid Value")
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Don't forget to reset when view is being removed
        AppUtility.lockOrientation(.all)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
