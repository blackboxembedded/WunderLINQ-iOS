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

import Foundation
import MapKit
import UIKit

/// All descriptions are accessible with option + click
enum NavigationAppPreference: Int, CaseIterable {
    /// Universal app link accessible with `maps://`
    case appleMaps = 0

    /// Universal app link accessible with `googlemaps://`, or x-callback `comgooglemaps-x-callback://`
    case googleMaps

    /// Integration guide: https://github.com/guidove/Scenic-Integration/blob/master/README.md
    /// https://scenicapp.space/api/openScenic.php is a deeplink with app-site-association
    case scenic

    /// https://www.sygic.com/developers/professional-navigation-sdk/ios/custom-url
    case sygic

    /// Universal app link accessible with `waze://`
    case waze

    /// https://github.com/mapsme/api-ios
    case mapsMe

    /// Universal app link accessible with `osmandmaps://?lat=45.6313&lon=34.9955&z=8&title=New+York`
    case osmAnd

    /// https://developer.here.com/documentation/mobility-on-demand-toolkit/dev_guide/topics/navigation.html
    /// Universal app link accessible with `here-route://mylocation/37.870090,-122.268150,Downtown%20Berkeley?ref=WunderLINQ&m=d`
    case hereWeGo

    /// https://discussions.tomtom.com/en/discussion/1118783/url-schemes-for-go-navigation-ios/
    /// Universal app link accessible with `tomtomgo://x-callback-url/navigate?destination=52.371183,4.892504`
    case tomTomGo

    /// http://carobapps.com/products/inroute/url-scheme/
    case inRoute

    /// Universal app link accessible with `mapout://`
    /// `mapout://longitude=-0.209659096912497345&latitude=51.52214776018867&zoom=8.6681337356567383&rotation=0`
    case mapout
    
    /// Universal app link accessible with `yjcarnavi://`
    /// https://note.com/yahoo_carnavi/n/n1d6b819a816c
    case yjcarnavi

    var isAvailable: Bool {
        UIApplication.shared.canOpenURL(URL(string: self.urlScheme)!)
    }

    var urlScheme: String {
        switch self {
        case .appleMaps:
            return "maps://"

        case .googleMaps:
            return "comgooglemaps-x-callback://?x-success=wunderlinq://&x-source=WunderLINQ"

        case .scenic:
            return ScenicAPI.Constants.deeplinkURL

        case .sygic:
            return "com.sygic.aura://"

        case .waze:
            return "waze://"

        case .hereWeGo:
            return "here-route://"

        case .mapsMe:
            return "mapsme://?backurl=wunderlinq://"

        case .osmAnd:
            return "osmandmaps://"

        case .tomTomGo:
            return "tomtomgo://"

        case .inRoute:
            return "inroute://"

        case .mapout:
            return "mapout://"
            
        case .yjcarnavi:
            return "yjcarnavi://"
        }
    }

    /// Interface to open an external navigation app with a universal link
    func open(_ app: UIApplication = .shared, url: URL) {

        guard isAvailable else {
            Self.appleMaps.open()
            return
        }

        app.open(url)
    }

    /// Interface to open an external navigation app with no arguments
    func open(_ app: UIApplication = .shared) {
        let url = URL(string: urlScheme)!
        open(url: url)
    }
}

class NavAppHelper {

    private let app: UIApplication

    init(_ app: UIApplication = .shared) {
        self.app = app
    }

    private func openAppleMaps() {
        NavigationAppPreference.appleMaps.open()
    }

    func open() {
        let navAppValue = UserDefaults.standard.integer(forKey: "nav_app_preference")
        guard let navApp = NavigationAppPreference(rawValue: navAppValue) else {
            openAppleMaps()
            return
        }
        navApp.open()
    }

}

extension NavAppHelper {
    class func navigateTo(destLatitude: Double, destLongitude: Double, destLabel: String?, currentLatitude: Double, currentLongitude: Double) {
        let navAppValue = UserDefaults.standard.integer(forKey: "nav_app_preference")
        guard let navApp = NavigationAppPreference(rawValue: navAppValue) else { return }

        switch navApp {
        case .appleMaps:
            let coordinates = CLLocationCoordinate2DMake(destLatitude, destLongitude)
            let navPlacemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapitem = MKMapItem(placemark: navPlacemark)
            let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            mapitem.openInMaps(launchOptions: options)

        case .googleMaps:
            if let googleMapsURL = URL(string: "\(navApp.urlScheme)?daddr=\(destLatitude),\(destLongitude)&directionsmode=driving&x-success=wunderlinq://?resume=true&x-source=WunderLINQ") {
                if (UIApplication.shared.canOpenURL(googleMapsURL)) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(googleMapsURL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(googleMapsURL as URL)
                    }
                }
            }
        case .scenic:
            let scenic = ScenicAPI()
            scenic.sendToScenicForNavigation(coordinate: CLLocationCoordinate2D(latitude: destLatitude,longitude: destLongitude), name: destLabel ?? "WunderLINQ")

        case .sygic:
            let urlString = "\(navApp.urlScheme)coordinate|\(destLongitude)|\(destLatitude)|drive"
            
            if let sygicURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(sygicURL)) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(sygicURL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(sygicURL as URL)
                    }
                }
            }

        case .waze:
            if let wazeURL = URL(string: "\(navApp.urlScheme)?ll=\(destLatitude),\(destLongitude)&navigate=yes") {
                if (UIApplication.shared.canOpenURL(wazeURL)) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(wazeURL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(wazeURL as URL)
                    }
                }
            }

        case .mapsMe:
            let urlString = "\(navApp.urlScheme)route?sll=\(currentLatitude),\(currentLongitude)&saddr=\(NSLocalizedString("trip_view_waypoint_start_label", comment: ""))&dll=\(destLatitude),\(destLongitude)&daddr=\(destLabel ?? ""))&type=vehicle&backurl=wunderlinq://"
            if let mapsMeURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(mapsMeURL)) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(mapsMeURL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(mapsMeURL as URL)
                    }
                }
            }

        case .osmAnd:
            let urlString = "\(navApp.urlScheme)navigate?lat=\(destLatitude)&lon=\(destLongitude)&z=8&title=\(destLabel ?? "")"
            if let mapsMeURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(mapsMeURL)) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(mapsMeURL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(mapsMeURL as URL)
                    }
                }
            }

        case .hereWeGo:
            let urlString = "\(navApp.urlScheme)mylocation/\(destLatitude),\(destLongitude),\(destLabel ?? "")?ref=WunderLINQ&m=d"
            if let hereURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(hereURL)) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(hereURL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(hereURL as URL)
                    }
                }
            }

        case .tomTomGo:
            // TomTom GO
            // https://discussions.tomtom.com/en/discussion/1118783/url-schemes-for-go-navigation-ios/
            // tomtomgo://x-callback-url/navigate?destination=52.371183,4.892504
            let urlString = "\(navApp.urlScheme)x-callback-url/navigate?destination=\(destLatitude),\(destLongitude)"
            if let uRL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(uRL)) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(uRL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(uRL as URL)
                    }
                }
            }

        case .inRoute:
            //inRoute
            //http://carobapps.com/products/inroute/url-scheme/
            let urlString = "\(navApp.urlScheme)coordinates?action=opt&loc=Start/\(currentLatitude)/\(currentLongitude)&loc=\(destLabel ?? "")/\(destLatitude)/\(destLongitude)"
            if let uRL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(uRL)) {
                    UIApplication.shared.open(uRL, options: [:], completionHandler: nil)
                }
            }

        case .mapout:
            var components = URLComponents()

            let queryItems = [URLQueryItem(name: "longitude", value: "\(destLongitude)"),
                              URLQueryItem(name: "latitude", value: "\(destLatitude)"),
                              URLQueryItem(name: "zoom", value: "8"),
                              URLQueryItem(name: "rotation", value: "0")]

            components.queryItems = queryItems
            components.scheme = navApp.urlScheme

            guard let url = components.url else {
                return
            }

            navApp.open(url: url)
            
        case .yjcarnavi:
            let urlString = "\(navApp.urlScheme)navi/select?lat=\(destLatitude)&lon=\(destLongitude)&name=\(destLabel ?? "")"
            if let uRL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(uRL)) {
                    UIApplication.shared.open(uRL, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    class func viewWaypoint(destLatitude: Double, destLongitude: Double, destLabel: String?) {
        let navApp = UserDefaults.standard.integer(forKey: "nav_app_preference")
        print("Open NavApp: \(navApp)")
        switch (navApp){
        case 0:
            //Apple Maps
            let regionDistance:CLLocationDistance = 10000
            let coordinates = CLLocationCoordinate2DMake(destLatitude, destLongitude)
            let regionSpan = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = destLabel
            mapItem.openInMaps(launchOptions: options)
        case 1:
            //Google Maps
            //https://developers.google.com/maps/documentation/urls/ios-urlscheme
            let urlString = "comgooglemaps-x-callback://?q=\(destLatitude),\(destLongitude)&x-success=wunderlinq://?resume=true&x-source=WunderLINQ"
            if let googleMapsURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                print("google map selected url")
                if (UIApplication.shared.canOpenURL(googleMapsURL)) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(googleMapsURL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(googleMapsURL as URL)
                    }
                }
            }
        case 2:
            //Scenic
            //https://github.com/guidove/Scenic-Integration/blob/master/README.md
            let lat: CLLocationDegrees = destLatitude
            let lon: CLLocationDegrees = destLongitude
            let scenic = ScenicAPI()
            scenic.sendToScenicForNavigation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), name: destLabel ?? "")
        case 3:
            //Sygic
            //https://www.sygic.com/developers/professional-navigation-sdk/ios/custom-url
            let urlString = "com.sygic.aura://coordinate|\(destLongitude)|\(destLatitude)|show"
            if let sygicURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(sygicURL)) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(sygicURL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(sygicURL as URL)
                    }
                }
            }
        case 4:
            //Waze
            // https://developers.google.com/waze/deeplinks/
            if let wazeURL = URL(string: "https://waze.com/ul?ll=\(destLatitude),\(destLongitude)&z=10") {
                if (UIApplication.shared.canOpenURL(wazeURL)) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(wazeURL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(wazeURL as URL)
                    }
                }
            }
        case 5:
            //Maps.me
            //https://github.com/mapsme/api-ios
            let urlString = "mapsme://map?ll=\(destLatitude),\(destLongitude)&n=\(destLabel ?? "")&backurl=wunderlinq://"
            if let mapsMeURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(mapsMeURL)) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(mapsMeURL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(mapsMeURL as URL)
                    }
                }
            }
        case 6:
            //OsmAnd
            // osmandmaps://?lat=45.6313&lon=34.9955&z=8&title=New+York
            let urlString = "osmandmaps://lat=\(destLatitude)&lon=\(destLongitude)&z=8&title=\(destLabel ?? "")"
            if let mapsMeURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(mapsMeURL)) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(mapsMeURL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(mapsMeURL as URL)
                    }
                }
            }
        case 7:
            // HERE WeGo
            // https://stackoverflow.com/questions/13514532/launch-nokia-here-maps-ios-via-api
            // here-location://lat,lon,optionalName
            let urlString = "here-location://\(destLatitude),\(destLongitude),\(destLabel ?? "")?ref=WunderLINQ"
            if let hereURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(hereURL)) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(hereURL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(hereURL as URL)
                    }
                }
            }
        case 8:
            // TomTom GO
            // https://discussions.tomtom.com/en/discussion/1118783/url-schemes-for-go-navigation-ios/
            // tomtomgo://x-callback-url/navigate?destination=52.371183,4.892504
            let urlString = "tomtomgo://x-callback-url/navigate?destination=\(destLatitude),\(destLongitude)"
            if let uRL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(uRL)) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(uRL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(uRL as URL)
                    }
                }
            }
        case 9:
            //inRoute
            //http://carobapps.com/products/inroute/url-scheme/
            let urlString = "inroute://coordinates?action=opt&loc=\(destLabel ?? "")/\(destLatitude)/\(destLongitude)"
            if let uRL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(uRL)) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(uRL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(uRL as URL)
                    }
                }
            }
        default:
            //Apple Maps
            let regionDistance: CLLocationDistance = 10000
            let coordinates = CLLocationCoordinate2DMake(destLatitude, destLongitude)
            let regionSpan = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = destLabel
            mapItem.openInMaps(launchOptions: options)
        }
    }
}
