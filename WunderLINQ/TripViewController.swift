//
//  TripViewController.swift
//  WunderLINQ
//
//  Created by Keith Conger on 7/23/18.
//  Copyright © 2018 Black Box Embedded, LLC. All rights reserved.
//

import UIKit
import GoogleMaps

class TripViewController: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var gearShiftsLabel: UILabel!
    @IBOutlet weak var brakesLabel: UILabel!
    @IBOutlet weak var ambientTempLabel: UILabel!
    @IBOutlet weak var engineTempLabel: UILabel!
    
    var fileName: String?
    var csvFileNames : [String]?
    var indexOfFileName: Int?
    
    @objc func leftScreen() {
        performSegue(withIdentifier: "tripToTrips", sender: [])
    }
    
    func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            if (indexOfFileName != 0){
                fileName = csvFileNames![indexOfFileName! - 1]
                self.viewDidLoad()
            }
        }
        else if gesture.direction == UISwipeGestureRecognizerDirection.left {
            if (indexOfFileName != (csvFileNames!.count - 1)){
                fileName = csvFileNames![indexOfFileName! + 1]
                self.viewDidLoad()
            }
        }
    }
    
    @IBAction func shareBtn(_ sender: Any) {
        let filename = "\(self.getDocumentsDirectory())/\(fileName!).csv"
        let fileURL = URL(fileURLWithPath: filename)
        let vc = UIActivityViewController(activityItems: [fileURL], applicationActivities: [])
        self.present(vc, animated: true)
    }
    
    @IBAction func deleteBtn(_ sender: Any) {
        let fileManager = FileManager.default
        let filename = "\(self.getDocumentsDirectory())/\(fileName ?? "file").csv"
        
        do {
            try fileManager.removeItem(atPath: filename)
        } catch {
            print("Could not delete file: \(error)")
        }
        performSegue(withIdentifier: "tripToTrips", sender: [])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppUtility.lockOrientation(.portrait)

        // Do any additional setup after loading the view.
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let backBtn = UIButton()
        backBtn.setImage(UIImage(named: "Left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        backBtn.addTarget(self, action: #selector(leftScreen), for: .touchUpInside)
        let backButton = UIBarButtonItem(customView: backBtn)
        let backButtonWidth = backButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        backButtonWidth?.isActive = true
        let backButtonHeight = backButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        backButtonHeight?.isActive = true
        self.navigationItem.title = NSLocalizedString("trip_view_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton]
        
        updateFileList()
        indexOfFileName = csvFileNames!.index(of: fileName!)

        var data = readDataFromCSV(fileName: "\(fileName!)", fileType: "csv")
        data = cleanRows(file: data!)
        let csvRows = csv(data: data!)
        
        let path = GMSMutablePath()
        var speeds : [Double] = []
        var maxSpeed: Double = 0
        var ambientTemps : [Double] = []
        var minAmbientTemp : Double?
        var maxAmbientTemp : Double?
        var engineTemps : [Double] = []
        var minEngineTemp : Double?
        var maxEngineTemp : Double?
        var startTime : String?
        var endTime : String?
        var startOdometer : Double?
        var endOdometer : Double?
        var endShiftCnt : Int = 0
        var endFrontBrakeCnt : Int = 0
        var endRearBrakeCnt : Int = 0
        
        var lineNumber = 0
        for row in csvRows{
            lineNumber = lineNumber + 1
            if (lineNumber == 2) {
                startTime = row[0]
            } else if ((lineNumber > 2) && (lineNumber < csvRows.count)){
                endTime = row[0]
            }
        
            if((lineNumber > 1) && (lineNumber < csvRows.count)) {
                if !(row[0].contains("No Fix") || row[1].contains("No Fix") || row[4].contains("No Fix")){
                    if let lat = row[1].toDouble(),let lon = row[2].toDouble() {
                        path.add(CLLocationCoordinate2D(latitude: lat, longitude: lon))
                    }
                    
                    if let speed = row[4].toDouble() {
                        if speed > 0 {
                            speeds.append(speed)
                            if (maxSpeed < speed){
                                maxSpeed = speed
                            }
                        }
                    }
                } else {
                    //no Fix
                }
                
            }
            if ((lineNumber > 1) && (lineNumber < csvRows.count)) {
                if !(row[6] == ""){
                    engineTemps.append(row[6].toDouble()!)
                    if (maxEngineTemp == nil || maxEngineTemp! < row[6].toDouble()!){
                        maxEngineTemp = row[6].toDouble()
                    }
                    if (minEngineTemp == nil || minEngineTemp! > row[6].toDouble()!){
                        minEngineTemp = row[6].toDouble()
                    }
                }
                if !(row[7] == ""){
                    ambientTemps.append(row[7].toDouble()!)
                    if (maxAmbientTemp == nil || maxAmbientTemp! < row[7].toDouble()!){
                        maxAmbientTemp = row[7].toDouble()
                    }
                    if (minAmbientTemp == nil || minAmbientTemp! > row[7].toDouble()!){
                        minAmbientTemp = row[7].toDouble()
                    }
                }
                if !(row[10] == ""){
                    if (endOdometer == nil || endOdometer! < row[10].toDouble()!){
                        endOdometer = row[10].toDouble()
                    }
                    if (startOdometer == nil || startOdometer! > row[10].toDouble()!){
                        startOdometer = row[10].toDouble()
                    }
                }
                if !(row[13] == ""){
                    if (endFrontBrakeCnt < row[13].toInt()!){
                        endFrontBrakeCnt = row[13].toInt()!
                    }
                }
                if !(row[14] == ""){
                    if (endRearBrakeCnt < row[14].toInt()!){
                        endRearBrakeCnt = row[14].toInt()!
                    }
                }
                if !(row[15] == ""){
                    if (endShiftCnt < row[15].toInt()!){
                        endShiftCnt = row[15].toInt()!
                    }
                }
            }
            if(lineNumber == 2){
                dateLabel.text = row[0]
            }
        }
        // TODO: read from CSV header
        var distanceUnit : String = "km"
        var speedUnit : String = "km/h"
        if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
            distanceUnit = "mi"
            speedUnit = "mi/h"
        }
        var temperatureUnit : String = "C";
        if UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 {
            // F
            temperatureUnit = "F";
        }
        
        if ((speeds.count) > 0){
            var avgSpeed : Double = 0.0
            for speed in speeds {
                avgSpeed = avgSpeed + speed
            }
            avgSpeed = avgSpeed / Double((speeds.count))
            if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                avgSpeed = kmToMiles(avgSpeed)
                maxSpeed = kmToMiles(maxSpeed)
            }
            speedLabel.text = "\(avgSpeed.rounded(toPlaces: 1))/\(maxSpeed.rounded(toPlaces: 1)) (\(speedUnit))"
        }
        
        gearShiftsLabel.text = "\(endShiftCnt)"
        
        brakesLabel.text = "\(endFrontBrakeCnt)/\(endRearBrakeCnt)"
        
        var avgEngineTemp: Double = 0
        if ((engineTemps.count) > 0) {
            for engineTemp in engineTemps {
                avgEngineTemp = avgEngineTemp + engineTemp
            }
            avgEngineTemp = avgEngineTemp / Double((ambientTemps.count))
            if UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 {
                // F
                minEngineTemp = celciusToFahrenheit(minEngineTemp!)
                avgEngineTemp = celciusToFahrenheit(avgEngineTemp)
                maxEngineTemp = celciusToFahrenheit(maxEngineTemp!)
            }
        }
        if(minEngineTemp == nil || maxEngineTemp == nil){
            minEngineTemp = 0.0
            maxEngineTemp = 0.0
        }
        engineTempLabel.text = "\(minEngineTemp!.rounded(toPlaces: 1))/\(avgEngineTemp.rounded(toPlaces: 1))/\(maxEngineTemp!.rounded(toPlaces: 1)) (\(temperatureUnit))"
        
        var avgAmbientTemp: Double = 0
        if ((ambientTemps.count) > 0) {
            for ambientTemp in ambientTemps {
                avgAmbientTemp = avgAmbientTemp + ambientTemp
            }
            avgAmbientTemp = avgAmbientTemp / Double(ambientTemps.count)
            if UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 {
                // F
                minAmbientTemp = celciusToFahrenheit(minAmbientTemp!)
                avgAmbientTemp = celciusToFahrenheit(avgAmbientTemp)
                maxAmbientTemp = celciusToFahrenheit(maxAmbientTemp!)
            }
        }
        if(minAmbientTemp == nil || maxAmbientTemp == nil){
            minAmbientTemp = 0.0
            maxAmbientTemp = 0.0
        }
        ambientTempLabel.text = "\(minAmbientTemp!.rounded(toPlaces: 1))/\(avgAmbientTemp.rounded(toPlaces: 1))/\(maxAmbientTemp!.rounded(toPlaces: 1)) (\(temperatureUnit))"
        
        // Calculate Distance
        var distance: Double = 0
        if (endOdometer != nil && startOdometer != nil) {
            distance = endOdometer! - startOdometer!
            if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                distance = kmToMiles(distance.rounded(toPlaces: 1))
            }
        }
        distanceLabel.text = "\(distance.rounded(toPlaces: 1)) \(distanceUnit)"
        
        // Calculate Duration
        durationLabel.text = calculateDuration(start: startTime!,end: endTime!)
        /*
        let bounds = GMSCoordinateBounds(path: path)
        let camera = mapView.camera(for: bounds, insets: UIEdgeInsets())!
        mapView.camera = camera
        mapView.mapType = .hybrid
        */
        mapView.clear()
        if path.count() > 0 {
            let bounds = GMSCoordinateBounds(path: path)
            let camera = mapView.camera(for: bounds, insets: UIEdgeInsets())!
            mapView.camera = camera
            mapView.mapType = .hybrid
            
            // Creates a marker in the center of the map.
            let startMarker = GMSMarker()
            startMarker.position = path.coordinate(at: 0)
            startMarker.title = NSLocalizedString("trip_view_waypoint_start_label", comment: "")
            startMarker.snippet = NSLocalizedString("trip_view_waypoint_start_label", comment: "")
            startMarker.icon = GMSMarker.markerImage(with: .green)
            startMarker.map = mapView
            
            let endMarker = GMSMarker()
            endMarker.position = path.coordinate(at: path.count() - 1)
            endMarker.title = NSLocalizedString("trip_view_waypoint_end_label", comment: "")
            endMarker.snippet = NSLocalizedString("trip_view_waypoint_end_label", comment: "")
            endMarker.icon = GMSMarker.markerImage(with: .red)
            endMarker.map = mapView
            
            let polyline = GMSPolyline(path: path)
            polyline.strokeColor = .red
            polyline.strokeWidth = 5.0
            polyline.map = mapView
            
            let cameraUpdate =  GMSCameraUpdate.fit(bounds, withPadding: 10.0)
            mapView.animate(with: cameraUpdate)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    func readDataFromCSV(fileName:String, fileType: String)-> String!{
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            print("\(fileName).\(fileType)")
            let fileURL = dir.appendingPathComponent("\(fileName).\(fileType)")
            
            //reading
            do {
                var contents = try String(contentsOf: fileURL, encoding: .utf8)
                contents = cleanRows(file: contents)
                //print(contents)
                return contents
            }
            catch {
                return nil
            }
        }
        return nil
    }    
    
    func cleanRows(file:String)->String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        return cleanFile
    }
    
    func csv(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ",")
            result.append(columns)
        }
        return result
    }
    // MARK: - Utility Methods
    // Unit Conversion Functions
    // bar to psi
    func barToPsi(_ bar:Double) -> Double {
        let psi = bar * 14.5037738
        return psi
    }
    // bar to kpa
    func barTokPa(_ bar:Double) -> Double {
        let kpa = bar * 100.0
        return kpa
    }
    // bar to kg-f
    func barTokgf(_ bar:Double) -> Double {
        let kgf = bar * 1.0197162129779
        return kgf
    }
    // kilometers to miles
    func kmToMiles(_ kilometers:Double) -> Double {
        let miles = kilometers * 0.6214
        return miles
    }
    // Celsius to Fahrenheit
    func celciusToFahrenheit(_ celcius:Double) -> Double {
        let fahrenheit = (celcius * 1.8) + Double(32)
        return fahrenheit
    }
    // Calculate time duration
    func calculateDuration(start:String, end:String) -> String{
        var dateFormat = "yyyyMMdd-HH:mm:ss"
        var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = dateFormat
            formatter.locale = Locale.current
            formatter.timeZone = TimeZone.current
            return formatter
        }
        let startDate = dateFormatter.date(from:start)!
        let endDate = dateFormatter.date(from:end)!
        let difference = Calendar.current.dateComponents([.hour, .minute, .second], from: startDate, to: endDate)

        return "\(difference.hour!) \(NSLocalizedString("hours", comment: "")), \(difference.minute!) \(NSLocalizedString("minutes", comment: "")), \(difference.second!) \(NSLocalizedString("seconds", comment: ""))"
    }
    func updateFileList(){
        // Get the document directory url
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            print(directoryContents)
            
            // if you want to filter the directory contents you can do like this:
            let csvFiles = directoryContents.filter{ $0.pathExtension == "csv" }
            csvFileNames = csvFiles.map{ $0.deletingPathExtension().lastPathComponent }
            csvFileNames = csvFileNames?.sorted(by: {$0 > $1})
            
            
        } catch {
            print(error.localizedDescription)
        }
    }
}
