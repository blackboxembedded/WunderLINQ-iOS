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
import GoogleMaps
import CoreGPX
import os.log

class TripViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var labelLabel: UITextField!
    @IBOutlet weak var gearShiftsLabel: UILabel!
    @IBOutlet weak var brakesLabel: UILabel!
    @IBOutlet weak var ambientTempLabel: UILabel!
    @IBOutlet weak var engineTempLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var leanLabel: UILabel!
    
    var fileName: String?
    var csvFileNames : [String]?
    var indexOfFileName: Int?
    
    var menuBtn: UIButton!
    var menuButton: UIBarButtonItem!
    
    @objc func leftScreen() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            if (indexOfFileName != 0){
                fileName = csvFileNames![indexOfFileName! - 1]
                self.viewDidLoad()
            }
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            if (indexOfFileName != (csvFileNames!.count - 1)){
                fileName = csvFileNames![indexOfFileName! + 1]
                self.viewDidLoad()
            }
        }
    }
    
    func share(){
        let filename = "\(self.getDocumentsDirectory())/\(fileName!).csv"
        let fileURL = URL(fileURLWithPath: filename)
        let vc = UIActivityViewController(activityItems: [fileURL], applicationActivities: [])
        self.present(vc, animated: true)
    }
    
    func exportGPX(){
        let root = GPXRoot(creator: "WunderLINQ")
        let track = GPXTrack()                          // inits a track
        let tracksegment = GPXTrackSegment()            // inits a tracksegment
        var trackpoints = [GPXTrackPoint]()
        
        var data = readDataFromCSV(fileName: "\(fileName!)", fileType: "csv")
        data = cleanRows(file: data!)
        var lineNumber = 0
        let csvRows = csv(data: data!)
        for row in csvRows{
            if((lineNumber > 0) && (lineNumber < csvRows.count - 1)) {
                if !(row[1].contains("No Fix") || row[2].contains("No Fix")){
                    if let lat = row[1].toDouble(),let lon = row[2].toDouble() {
                        let trackpoint = GPXTrackPoint(latitude: lat, longitude: lon)
                        let dateFormat = "yyyyMMdd-HH:mm:ss.SSS"
                        var dateFormatter: DateFormatter {
                            let formatter = DateFormatter()
                            formatter.dateFormat = dateFormat
                            formatter.locale = Locale(identifier: "en_US")
                            formatter.timeZone = TimeZone.current
                            return formatter
                        }
                        let time = dateFormatter.date(from:row[0])!
                        trackpoint.time = time // set time to current date
                        trackpoints.append(trackpoint)
                    }
                } else {
                    //no Fix
                }
                
            }
            
            lineNumber = lineNumber + 1
        }
        tracksegment.add(trackpoints: trackpoints)      // adds an array of trackpoints to a track segment
        track.add(trackSegment: tracksegment)           // adds a track segment to a track
        root.add(track: track)                          // adds a track

        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        do {
            let array = fileName!.components(separatedBy: ".")
            try root.outputToFile(saveAt: url, fileName: array[0])
            let fileURL = url.appendingPathComponent("\(array[0]).gpx")
            let vc = UIActivityViewController(activityItems: [fileURL], applicationActivities: [])
            self.present(vc, animated: true)
        } catch {
            print(StaticString("TripViewController: exportGPX: %{PUBLIC}@"), error.localizedDescription)
        }
    }
    
    func delete(){
        let alert = UIAlertController(title: NSLocalizedString("delete_trip_alert_title", comment: ""), message: NSLocalizedString("delete_trip_alert_body", comment: ""), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("delete_bt", comment: ""), style: UIAlertAction.Style.default, handler: { action in
            let fileManager = FileManager.default
            let filename = "\(self.getDocumentsDirectory())/\(self.fileName ?? "file").csv"
            
            do {
                try fileManager.removeItem(atPath: filename)
            } catch {
                NSLog("TripViewController: Could not delete file: \(error)")
            }
            self.performSegue(withIdentifier: "tripToTrips", sender: [])
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel_bt", comment: ""), style: UIAlertAction.Style.cancel, handler: { action in
            // close
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let backBtn = UIButton()
        backBtn.setImage(UIImage(named: "Left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        backBtn.tintColor = UIColor(named: "imageTint")
        backBtn.addTarget(self, action: #selector(leftScreen), for: .touchUpInside)
        let backButton = UIBarButtonItem(customView: backBtn)
        let backButtonWidth = backButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        backButtonWidth?.isActive = true
        let backButtonHeight = backButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        backButtonHeight?.isActive = true
        menuBtn = UIButton()
        menuBtn.setImage(UIImage(named: "Menu")?.withRenderingMode(.alwaysTemplate), for: .normal)
        menuBtn.tintColor = UIColor(named: "imageTint")
        let menuButton = UIBarButtonItem(customView: menuBtn)
        let menuButtonWidth = menuButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        menuButtonWidth?.isActive = true
        let menuButtonHeight = menuButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        menuButtonHeight?.isActive = true
        self.navigationItem.title = NSLocalizedString("trip_view_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton]
        self.navigationItem.rightBarButtonItems = [menuButton]

        // Data source: array of (title, action) tuples
        let dataSource: [(title: String, action: () -> Void)] = [
            (NSLocalizedString("waypoint_view_bt_share", comment: ""), { self.share() }),
            (NSLocalizedString("share_gpx", comment: ""), { self.exportGPX() }),
            (NSLocalizedString("waypoint_view_bt_delete", comment: ""), { self.delete() })
        ]

        // Create UIActions with unique closures
        let menuChildren: [UIAction] = dataSource.map { item in
            return UIAction(title: item.title) { _ in
                item.action()
            }
        }

        // Create menu and assign to button
        menuBtn.menu = UIMenu(title: "", options: .displayInline, children: menuChildren)
        menuBtn.showsMenuAsPrimaryAction = true

        // Layout
        menuBtn.frame = CGRect(x: 150, y: 200, width: 160, height: 40)
        view.addSubview(menuBtn)
        
        self.labelLabel.delegate = self
        labelLabel.placeholder = NSLocalizedString("trip_view_label_hint", comment: "")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        updateFileList()
        indexOfFileName = csvFileNames!.firstIndex(of: fileName!)
        labelLabel.text = fileName
        let rawData = readDataFromCSV(fileName: "\(fileName!)", fileType: "csv")
        if (rawData != nil){
            let data = cleanRows(file: rawData!)
            let csvRows = csv(data: data)
            
            let path = GMSMutablePath()
            var lastLocation : CLLocation?
            var totalDistance : Double = 0
            var speeds : [Double] = []
            var maxSpeed: Double = 0
            var maxLean : Double?
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
            var dateFormat = "yyyyMMdd-HH:mm:ss"
            
            var lineNumber = 0
            for row in csvRows{
                lineNumber = lineNumber + 1
                if (lineNumber == 2) {
                    startTime = row[0]
                    //Check date format
                    if let fourthFromEnd = row[0].suffix(4).dropLast(3).last, fourthFromEnd == "." {
                        dateFormat = "yyyyMMdd-HH:mm:ss.SSS"
                    }
                } else if ((lineNumber > 2) && (lineNumber < csvRows.count)){
                    endTime = row[0]
                }
            
                if((lineNumber > 1) && (lineNumber < csvRows.count)) {
                    if !(row[1].contains("No Fix") || row[2].contains("No Fix")){
                        if let lat = row[1].toDouble(),let lon = row[2].toDouble() {
                            path.add(CLLocationCoordinate2D(latitude: lat, longitude: lon))
                            let location = CLLocation(latitude: lat, longitude: lon)
                            if (lastLocation == nil){
                                lastLocation = location
                            } else {
                                totalDistance += lastLocation!.distance(from: location)
                            }
                        }
                    }
                    if !row[4].contains("No Fix"){
                        if let speed = row[4].toDouble() {
                            if speed > 0 {
                                speeds.append(speed)
                                if (maxSpeed < speed){
                                    maxSpeed = speed
                                }
                            }
                        }
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
                    if !(row[32] == ""){
                        if (maxLean ?? 0.0 < row[32].toDouble()!){
                            maxLean = row[32].toDouble()!
                        }
                    } else if !(row[27] == ""){
                        if (maxLean ?? 0.0 < row[27].toDouble()!){
                            maxLean = row[27].toDouble()!
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
                    avgSpeed = Utils.kmToMiles(avgSpeed)
                    maxSpeed = Utils.kmToMiles(maxSpeed)
                }
                speedLabel.text = "\(Utils.toOneDecimalString(avgSpeed))/\(Utils.toOneDecimalString(maxSpeed)) (\(speedUnit))"
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
                    minEngineTemp = Utils.celciusToFahrenheit(minEngineTemp!)
                    avgEngineTemp = Utils.celciusToFahrenheit(avgEngineTemp)
                    maxEngineTemp = Utils.celciusToFahrenheit(maxEngineTemp!)
                }
            }
            if(minEngineTemp == nil || maxEngineTemp == nil){
                minEngineTemp = 0.0
                maxEngineTemp = 0.0
            }
            engineTempLabel.text = "\(Utils.toOneDecimalString(minEngineTemp!))/\(Utils.toOneDecimalString(avgEngineTemp))/\(Utils.toOneDecimalString(maxEngineTemp!)) (\(temperatureUnit))"
            
            var avgAmbientTemp: Double = 0
            if ((ambientTemps.count) > 0) {
                for ambientTemp in ambientTemps {
                    avgAmbientTemp = avgAmbientTemp + ambientTemp
                }
                avgAmbientTemp = avgAmbientTemp / Double(ambientTemps.count)
                if UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 {
                    // F
                    minAmbientTemp = Utils.celciusToFahrenheit(minAmbientTemp!)
                    avgAmbientTemp = Utils.celciusToFahrenheit(avgAmbientTemp)
                    maxAmbientTemp = Utils.celciusToFahrenheit(maxAmbientTemp!)
                }
            }
            if(minAmbientTemp == nil || maxAmbientTemp == nil){
                minAmbientTemp = 0.0
                maxAmbientTemp = 0.0
            }
            ambientTempLabel.text = "\(Utils.toOneDecimalString(minAmbientTemp!))/\(Utils.toOneDecimalString(avgAmbientTemp))/\(Utils.toOneDecimalString(maxAmbientTemp!)) (\(temperatureUnit))"
            
            // Calculate Distance
            var distance: Double = 0
            if (endOdometer != nil && startOdometer != nil) {
                distance = endOdometer! - startOdometer!
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    distance = Utils.kmToMiles(distance.rounded(toPlaces: 1))
                }
            } else if (totalDistance > 0) {
                distance = totalDistance / 1000
            }
            distanceLabel.text = "\(Utils.toOneDecimalString(distance)) \(distanceUnit)"
            
            // Calculate Duration
            if ((startTime != nil) && (endTime != nil)){
                durationLabel.text = Utils.calculateDuration(dateFormat: dateFormat, start: startTime!,end: endTime!)
            }
            
            if (maxLean != nil){
                leanLabel.text = "\(Utils.toOneDecimalString(maxLean!))"
            }

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
            NSLog("TripViewController: \(fileName).\(fileType)")
            let fileURL = dir.appendingPathComponent("\(fileName).\(fileType)")
            
            //reading
            do {
                var contents = try String(contentsOf: fileURL, encoding: .utf8)
                contents = cleanRows(file: contents)
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

        let rows = data.components(separatedBy: .newlines)
        for row in rows where !row.isEmpty {
            var columns: [String] = []
            var value = ""
            var inQuotes = false
            var chars = row.makeIterator()
            var c = chars.next()

            while let current = c {
                if current == "\"" {
                    if inQuotes {
                        let next = chars.next()
                        if next == "\"" {
                            // Escaped quote
                            value.append("\"")
                            c = chars.next()
                            continue
                        } else {
                            // Closing quote
                            inQuotes = false
                            c = next
                            continue
                        }
                    } else {
                        // Opening quote
                        inQuotes = true
                        c = chars.next()
                        continue
                    }
                } else if current == "," && !inQuotes {
                    columns.append(value)
                    value = ""
                } else {
                    value.append(current)
                }
                c = chars.next()
            }
            columns.append(value) // Append the last value
            result.append(columns)
        }

        return result
    }


    func updateFileList(){
        // Get the document directory url
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            
            // if you want to filter the directory contents you can do like this:
            let csvFiles = directoryContents.filter{ $0.pathExtension == "csv" }
            csvFileNames = csvFiles.map{ $0.deletingPathExtension().lastPathComponent }
            csvFileNames = csvFileNames?.sorted(by: {$0 > $1})
            
            
        } catch {
            print(StaticString("TripViewController: updateFileList: %{PUBLIC}@"), error.localizedDescription)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //Update filename
        let fileManager = FileManager.default
        if (fileName != nil){
            do {
                let oldURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName! + ".csv")
                let newURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent((labelLabel.text ?? "empty") + ".csv")
                
            try fileManager.moveItem(at: oldURL, to: newURL)
                    NSLog("TripViewController: File renamed successfully")
            } catch {
                    NSLog("TripViewController: Error renaming file: \(error)")
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size else { return }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        view.frame.origin.y -= contentInsets.bottom
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }

}
