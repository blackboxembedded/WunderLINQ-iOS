//
//  ScenicAPI.swift
//
//  Created by Pinguido
//  Copyright © 2016 Pinguido. All rights reserved.
//


import Foundation
import UIKit
import CoreLocation

class ScenicAPI {
    
    
    //  All functions attempt to open the Scenic App on the users' device.
    //  If Scenic is not on the device the App Store App will open on the Scenic Download Page.
    
    
    
    /**************************************************************
     **************   Send GPX URL for IMPORT    *******************
     ***************************************************************
     ****  gpxurl (required): the url to the gpx file (has to be direct link, no html wrappers like a dropbox link for example)
     ***************************************************************
     ****  the route name and description will be extracted from the GPX file
     ****  if the GPX contains more routes, tracks and/or waypoints they can all be imported by the user
     **************************************************************/
    
    func sendToScenicForImport(gpxurl: String) {
        if let encodedgpxurl = gpxurl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            let param = "gpxurl=\(encodedgpxurl)"
            self.getCopiedGPXURL("import/gpxurl", parameters: param) { (error, url) -> Void in
                if !error {
                    self.sendGPXURL(url!)
                }
            }
        }
        else {
            self.showErrorAlert("Error", message: "The Route Data could not be processed")
        }
    }
    
    
    
    
    /**************************************************************
     *****               Send Polyline for IMPORT          *********
     ***************************************************************
     ****  polyline (required): Encoded Polyline (String) (https://developers.google.com/maps/documentation/utilities/polylinealgorithm)
     ****  name (optional): the name of the route (String)
     ****  descr (optional): the description of the route (String)
     **************************************************************/
    
    func sendToScenicForImport(polyline: String, name: String = "", descr: String = "") {
        if let encodedname = name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
            let encodeddescr = descr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            let param = "polyline=\(polyline)&name=\(encodedname)&descr=\(encodeddescr)"
            self.getCopiedGPXURL("import/polyline", parameters: param) { (error, url) -> Void in
                if !error {
                    self.sendGPXURL(url!)
                }
            }
        }
        else {
            self.showErrorAlert("Error", message: "The Route Data could not be processed")
        }
        
    }
    
    
    
    
    /**************************************************************
     ************       Send Coordinates for IMPORT      **********
     **************************************************************
     ****  coordinates (required): Array of coordinates (latitude,longitude) (Array<CLLocationCoordinate2D>)
     ****  name (optional): the name of the route (String)
     ****  descr (optional): the description of the route (String)
     **************************************************************/
    
    func sendToScenicForImport(coordinates: Array<CLLocationCoordinate2D>, name: String = "", descr: String = "") {
        if let encodedname = name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
            let encodeddescr = descr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            let param = "coordinates=\(stringOfCLLocationArray(coordinates))&name=\(encodedname)&descr=\(encodeddescr)"
            self.getCopiedGPXURL("import/coordinates", parameters: param) { (error, url) -> Void in
                if !error {
                    self.sendGPXURL(url!)
                }
            }
        }
        else {
            self.showErrorAlert("Error", message: "The Route Data could not be processed")
        }
        
    }
    
    
    
    
    /**************************************************************
     *****               Send Polyline for Navigation     *********
     ***************************************************************
     ****  polyline (required): Encoded Polyline (String) (https://developers.google.com/maps/documentation/utilities/polylinealgorithm)
     ****  the polyline has to contain at least 2 coordinates and at the most 200 coordinates
     ****  name (optional): the name of the route (String)
     ****  routeMode (Optional): RouteMode.fast, .short, .efficient (Defaults to .fast)
     ****  vehicleType (Optional): VehicleType.carMotorcycle, .bicycle, .pedestrian (Defaults to .carMotorcycle)
     **************************************************************/
    
    func sendToScenicForNavigation(polyline: String, name: String = "", routeMode: RouteMode = RouteMode.fast, vehicleType: VehicleType = VehicleType.carMotorcycle) {
        self.sendPolyline(polyline, name: name, routeMode: routeMode, vehicleType: vehicleType)
    }
    
    
    
    
    /**************************************************************
     ************       Send Coordinates for Navigation      ******
     **************************************************************
     ****  coordinates (required): Array of coordinates (latitude,longitude) (Array<CLLocationCoordinate2D>)
     ****  - 6 digits precision for the lat and lon components is sufficient
     ****  - there should be at least 2 coordinate and at the most 200 coordinates
     ****  name (optional): the name of the route (String)
     ****  routeMode (Optional): RouteMode.fast, .short, .efficient (Defaults to .fast)
     ****  vehicleType (Optional): VehicleType.carMotorcycle, .bicycle, .pedestrian (Defaults to .carMotorcycle)
     **************************************************************/
    
    func sendToScenicForNavigation(coordinates: Array<CLLocationCoordinate2D>, name: String = "", routeMode: RouteMode = RouteMode.fast, vehicleType: VehicleType = VehicleType.carMotorcycle) {
        let polyline: String = encodeCoordinates(coordinates)
        self.sendPolyline(polyline, name: name, routeMode: routeMode, vehicleType: vehicleType)
    }
    
    
    /*************************************************************
     ************ Send Single Coordinate for NAVIGATION ***********
     **************************************************************
     ****  coordinate: Coordinate (CLLLocationCoordinate2D)
     ****  - 6 digits precision for the lat and lon components is sufficient
     ****  name (optional): the name of the route (String)
     **************************************************************/
    
    func sendToScenicForNavigation(coordinate: CLLocationCoordinate2D, name: String = "") {
        let stringOfCoordinate = "\(coordinate.latitude.toNonScientificString()),\(coordinate.longitude.toNonScientificString())"
        self.sendCoordinate(stringOfCoordinate, name: name)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    /**************************************************************
     ***********************    Helper Functions     **************
     *************************************************************/
    fileprivate func stringOfCLLocationArray(_ cllArray: [CLLocationCoordinate2D]) -> String {
        var str = ""
        for location in cllArray {
            str += "\(location.latitude.toNonScientificString()),\(location.longitude.toNonScientificString())|"
        }
        return String(str.characters.dropLast())
    }
    
    fileprivate func sendGPXURL(_ gpxurl: String) {
        var urlComponents = URLComponents(string: "https://scenicapp.space/api/openScenic.php")!
        let encodedgpxurl = gpxurl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        urlComponents.queryItems = [
            URLQueryItem(name: "gpxurl", value: encodedgpxurl)
        ]
        UIApplication.shared.open(urlComponents.url!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
    
    fileprivate func sendPolyline(_ polyline: String, name: String, routeMode: RouteMode, vehicleType: VehicleType) {
        var urlComponents = URLComponents(string: "https://scenicapp.space/api/openScenic.php")!
        urlComponents.queryItems = [
            URLQueryItem(name: "navigatepolyline", value: polyline),
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "routeMode", value: routeMode.rawValue),
            URLQueryItem(name: "vehicleType", value: vehicleType.rawValue)
            
        ]
        UIApplication.shared.open(urlComponents.url!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
    
    fileprivate func sendCoordinate(_ coordinate: String, name: String) {
        var urlComponents = URLComponents(string: "https://scenicapp.space/api/openScenic.php")!
        urlComponents.queryItems = [
            URLQueryItem(name: "navigatelocation", value: coordinate),
            URLQueryItem(name: "name", value: name)
            
        ]
        UIApplication.shared.open(urlComponents.url!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
    
    
    
    fileprivate func getCopiedGPXURL(_ endpoint: String, parameters: String, compHandler:@escaping (_ error: Bool, _ gpxurl: String?) ->()) {
        let params = "fromOtherApp=1&\(parameters)"
        
        let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
        var dataTask: URLSessionDataTask?
        let urlString = "https://scenicapp.space/api/\(endpoint)"
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        let data = params.data(using: .utf8)
        print("JsonData")
        //request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        
        dataTask = defaultSession.dataTask(with: request, completionHandler: {
            data, response, error in
            if let error = error {
                print(error.localizedDescription)
            }
            else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        if let data = data {
                            print(data)
                            if let json = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as? Dictionary<String,String> {
                                print(json)
                                if let gpxurl = json["gpxurl"] {
                                    compHandler(false, gpxurl)
                                    return
                                } else {
                                    print("Results key not found in dictionary")
                                }
                            }
                            else {
                                print("Could not serialize JSON")
                            }
                        } else {
                            print("JSON Error")
                        }
                    } catch let error as NSError {
                        print("Error parsing results: \(error.localizedDescription)")
                    }
                }
            }
            self.showErrorAlert("Error", message: "Connection to Scenic failed or incorrect data received.")
            compHandler(true, nil)
        })
        dataTask?.resume()
    }
    
    
    fileprivate func showErrorAlert(_ title: String, message: String) {
        func presentFromController(_ controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
            if let navVC = controller as? UINavigationController,
                let visibleVC = navVC.visibleViewController {
                presentFromController(visibleVC, animated: animated, completion: completion)
            }
            else {
                if let tabVC = controller as? UITabBarController, let selectedVC = tabVC.selectedViewController {
                    presentFromController(selectedVC, animated: animated, completion: completion)
                }
                else {
                    print("Presenting")
                    controller.present(controller, animated: animated, completion: completion);
                }
            }
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            if let presentingVC = rootVC.presentingViewController {
                presentFromController(presentingVC, animated: true, completion: nil)
            }
        }
    }
}

fileprivate extension Double {
    func toNonScientificString() -> String {
        if self < 0.000001 && self > -0.000001 {
            return "0.000000"
        }
        return String(format: "%.6f", self)
    }
}


public struct Polyline {
    
    /// The array of coordinates (nil if polyline cannot be decoded)
    public let coordinates: [CLLocationCoordinate2D]?
    /// The encoded polyline
    public let encodedPolyline: String
    
    /// The array of levels (nil if cannot be decoded, or is not provided)
    public let levels: [UInt32]?
    /// The encoded levels (nil if cannot be encoded, or is not provided)
    public let encodedLevels: String?
    
    /// The array of location (computed from coordinates)
    public var locations: [CLLocation]? {
        return self.coordinates.map(toLocations)
    }
    
    // MARK: - Public Methods -
    
    /// This designated initializer encodes a `[CLLocationCoordinate2D]`
    ///
    /// - parameter coordinates: The `Array` of `CLLocationCoordinate2D` that you want to encode
    /// - parameter levels: The optional `Array` of levels  that you want to encode (default: `nil`)
    /// - parameter precision: The precision used for encoding (default: `1e5`)
    public init(coordinates: [CLLocationCoordinate2D], levels: [UInt32]? = nil, precision: Double = 1e5) {
        
        self.coordinates = coordinates
        self.levels = levels
        
        encodedPolyline = encodeCoordinates(coordinates, precision: precision)
        
        encodedLevels = levels.map(encodeLevels)
    }
    
    /// This designated initializer decodes a polyline `String`
    ///
    /// - parameter encodedPolyline: The polyline that you want to decode
    /// - parameter encodedLevels: The levels that you want to decode (default: `nil`)
    /// - parameter precision: The precision used for decoding (default: `1e5`)
    public init(encodedPolyline: String, encodedLevels: String? = nil, precision: Double = 1e5) {
        
        self.encodedPolyline = encodedPolyline
        self.encodedLevels = encodedLevels
        
        coordinates = decodePolyline(encodedPolyline, precision: precision)
        
        levels = self.encodedLevels.flatMap(decodeLevels)
    }
    
    /// This init encodes a `[CLLocation]`
    ///
    /// - parameter locations: The `Array` of `CLLocation` that you want to encode
    /// - parameter levels: The optional array of levels  that you want to encode (default: `nil`)
    /// - parameter precision: The precision used for encoding (default: `1e5`)
    public init(locations: [CLLocation], levels: [UInt32]? = nil, precision: Double = 1e5) {
        
        let coordinates = toCoordinates(locations)
        self.init(coordinates: coordinates, levels: levels, precision:precision)
    }
}

// MARK: - Public Functions -

/// This function encodes an `[CLLocationCoordinate2D]` to a `String`
///
/// - parameter coordinates: The `Array` of `CLLocationCoordinate2D` that you want to encode
/// - parameter precision: The precision used to encode coordinates (default: `1e5`)
///
/// - returns: A `String` representing the encoded Polyline
public func encodeCoordinates(_ coordinates: [CLLocationCoordinate2D], precision: Double = 1e5) -> String {
    
    var previousCoordinate = IntegerCoordinates(0, 0)
    var encodedPolyline = ""
    
    for coordinate in coordinates {
        let intLatitude  = Int(round(coordinate.latitude * precision))
        let intLongitude = Int(round(coordinate.longitude * precision))
        
        let coordinatesDifference = (intLatitude - previousCoordinate.latitude, intLongitude - previousCoordinate.longitude)
        
        encodedPolyline += encodeCoordinate(coordinatesDifference)
        
        previousCoordinate = (intLatitude,intLongitude)
    }
    
    return encodedPolyline
}

/// This function encodes an `[CLLocation]` to a `String`
///
/// - parameter coordinates: The `Array` of `CLLocation` that you want to encode
/// - parameter precision: The precision used to encode locations (default: `1e5`)
///
/// - returns: A `String` representing the encoded Polyline
public func encodeLocations(_ locations: [CLLocation], precision: Double = 1e5) -> String {
    
    return encodeCoordinates(toCoordinates(locations), precision: precision)
}

/// This function encodes an `[UInt32]` to a `String`
///
/// - parameter levels: The `Array` of `UInt32` levels that you want to encode
///
/// - returns: A `String` representing the encoded Levels
public func encodeLevels(_ levels: [UInt32]) -> String {
    return levels.reduce("") {
        $0 + encodeLevel($1)
    }
}

/// This function decodes a `String` to a `[CLLocationCoordinate2D]?`
///
/// - parameter encodedPolyline: `String` representing the encoded Polyline
/// - parameter precision: The precision used to decode coordinates (default: `1e5`)
///
/// - returns: A `[CLLocationCoordinate2D]` representing the decoded polyline if valid, `nil` otherwise
public func decodePolyline(_ encodedPolyline: String, precision: Double = 1e5) -> [CLLocationCoordinate2D]? {
    
    let data = encodedPolyline.data(using: String.Encoding.utf8)!
    
    let byteArray = unsafeBitCast((data as NSData).bytes, to: UnsafePointer<Int8>.self)
    let length = Int(data.count)
    var position = Int(0)
    
    var decodedCoordinates = [CLLocationCoordinate2D]()
    
    var lat = 0.0
    var lon = 0.0
    
    while position < length {
        
        do {
            let resultingLat = try decodeSingleCoordinate(byteArray: byteArray, length: length, position: &position, precision: precision)
            lat += resultingLat
            
            let resultingLon = try decodeSingleCoordinate(byteArray: byteArray, length: length, position: &position, precision: precision)
            lon += resultingLon
        } catch {
            return nil
        }
        
        decodedCoordinates.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
    }
    
    return decodedCoordinates
}

/// This function decodes a String to a [CLLocation]?
///
/// - parameter encodedPolyline: String representing the encoded Polyline
/// - parameter precision: The precision used to decode locations (default: 1e5)
///
/// - returns: A [CLLocation] representing the decoded polyline if valid, nil otherwise
public func decodePolyline(_ encodedPolyline: String, precision: Double = 1e5) -> [CLLocation]? {
    
    return decodePolyline(encodedPolyline, precision: precision).map(toLocations)
}

/// This function decodes a `String` to an `[UInt32]`
///
/// - parameter encodedLevels: The `String` representing the levels to decode
///
/// - returns: A `[UInt32]` representing the decoded Levels if the `String` is valid, `nil` otherwise
public func decodeLevels(_ encodedLevels: String) -> [UInt32]? {
    var remainingLevels = encodedLevels.unicodeScalars
    var decodedLevels   = [UInt32]()
    
    while remainingLevels.count > 0 {
        
        do {
            let chunk = try extractNextChunk(&remainingLevels)
            let level = decodeLevel(chunk)
            decodedLevels.append(level)
        } catch {
            return nil
        }
    }
    
    return decodedLevels
}


// MARK: - Private -

// MARK: Encode Coordinate

private func encodeCoordinate(_ locationCoordinate: IntegerCoordinates) -> String {
    
    let latitudeString  = encodeSingleComponent(locationCoordinate.latitude)
    let longitudeString = encodeSingleComponent(locationCoordinate.longitude)
    
    return latitudeString + longitudeString
}

private func encodeSingleComponent(_ value: Int) -> String {
    
    var intValue = value
    
    if intValue < 0 {
        intValue = intValue << 1
        intValue = ~intValue
    } else {
        intValue = intValue << 1
    }
    
    return encodeFiveBitComponents(intValue)
}

// MARK: Encode Levels

private func encodeLevel(_ level: UInt32) -> String {
    return encodeFiveBitComponents(Int(level))
}

private func encodeFiveBitComponents(_ value: Int) -> String {
    var remainingComponents = value
    
    var fiveBitComponent = 0
    var returnString = String()
    
    repeat {
        fiveBitComponent = remainingComponents & 0x1F
        
        if remainingComponents >= 0x20 {
            fiveBitComponent |= 0x20
        }
        
        fiveBitComponent += 63
        
        let char = UnicodeScalar(fiveBitComponent)!
        returnString.append(String(char))
        remainingComponents = remainingComponents >> 5
    } while (remainingComponents != 0)
    
    return returnString
}

// MARK: Decode Coordinate

// We use a byte array (UnsafePointer<Int8>) here for performance reasons. Check with swift 2 if we can
// go back to using [Int8]
private func decodeSingleCoordinate(byteArray: UnsafePointer<Int8>, length: Int, position: inout Int, precision: Double = 1e5) throws -> Double {
    
    guard position < length else { throw PolylineError.singleCoordinateDecodingError }
    
    let bitMask = Int8(0x1F)
    
    var coordinate: Int32 = 0
    
    var currentChar: Int8
    var componentCounter: Int32 = 0
    var component: Int32 = 0
    
    repeat {
        currentChar = byteArray[position] - 63
        component = Int32(currentChar & bitMask)
        coordinate |= (component << (5*componentCounter))
        position += 1
        componentCounter += 1
    } while ((currentChar & 0x20) == 0x20) && (position < length) && (componentCounter < 6)
    
    if (componentCounter == 6) && ((currentChar & 0x20) == 0x20) {
        throw PolylineError.singleCoordinateDecodingError
    }
    
    if (coordinate & 0x01) == 0x01 {
        coordinate = ~(coordinate >> 1)
    } else {
        coordinate = coordinate >> 1
    }
    
    return Double(coordinate) / precision
}

// MARK: Decode Levels

private func extractNextChunk(_ encodedString: inout String.UnicodeScalarView) throws -> String {
    var currentIndex = encodedString.startIndex
    
    while currentIndex != encodedString.endIndex {
        let currentCharacterValue = Int32(encodedString[currentIndex].value)
        if isSeparator(currentCharacterValue) {
            let extractedScalars = encodedString[encodedString.startIndex...currentIndex]
            //encodedString = encodedString[encodedString.index(after: currentIndex)..<encodedString.endIndex]
            
            return String(extractedScalars)
        }
        
        currentIndex = encodedString.index(after: currentIndex)
    }
    
    throw PolylineError.chunkExtractingError
}

private func decodeLevel(_ encodedLevel: String) -> UInt32 {
    let scalarArray = [] + encodedLevel.unicodeScalars
    
    return UInt32(agregateScalarArray(scalarArray))
}

private func agregateScalarArray(_ scalars: [UnicodeScalar]) -> Int32 {
    let lastValue = Int32(scalars.last!.value)
    
    let fiveBitComponents: [Int32] = scalars.map { scalar in
        let value = Int32(scalar.value)
        if value != lastValue {
            return (value - 63) ^ 0x20
        } else {
            return value - 63
        }
    }
    
    return Array(fiveBitComponents.reversed()).reduce(0) { ($0 << 5 ) | $1 }
}

// MARK: Utilities

enum PolylineError: Error {
    case singleCoordinateDecodingError
    case chunkExtractingError
}

private func toCoordinates(_ locations: [CLLocation]) -> [CLLocationCoordinate2D] {
    return locations.map {location in location.coordinate}
}

private func toLocations(_ coordinates: [CLLocationCoordinate2D]) -> [CLLocation] {
    return coordinates.map { coordinate in
        CLLocation(latitude:coordinate.latitude, longitude:coordinate.longitude)
    }
}

private func isSeparator(_ value: Int32) -> Bool {
    return (value - 63) & 0x20 != 0x20
}

private typealias IntegerCoordinates = (latitude: Int, longitude: Int)

public enum RouteMode: String {
    case fast = "F"
    case short = "S"
    case efficient = "E"
}

public enum VehicleType: String {
    case carMotorcycle = "C"
    case bicycle = "B"
    case pedestrian = "P"
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
