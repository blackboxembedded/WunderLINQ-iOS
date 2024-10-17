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

    case appleMaps = 0

    case googleMaps

    case scenic

    case sygic

    case waze

    case mapsMe

    case osmAnd

    case hereWeGo

    case tomTomGo

    case inRoute

    case mapout

    case yahooJapan

    case copilot

    case yandex

    case cartograph

    case organicmaps

    case gurumaps

    case myrouteapp
    
    case calimoto
    
    case kurviger
    
    var isAvailable: Bool {
        UIApplication.shared.canOpenURL(URL(string: self.urlScheme)!)
    }

    var urlScheme: String {
        switch self {
        case .appleMaps:
            return "maps://"

        case .googleMaps:
            return "comgooglemaps-x-callback://"

        case .scenic:
            return ScenicAPI.Constants.deeplinkURL

        case .sygic:
            return "com.sygic.aura://"

        case .waze:
            return "waze://"

        case .hereWeGo:
            return "here-route://"

        case .mapsMe:
            return "mapsme://"

        case .osmAnd:
            return "osmandmaps://"

        case .tomTomGo:
            return "tomtomgo://"

        case .inRoute:
            return "inroute://"

        case .mapout:
            return "mapout://"
            
        case .yahooJapan:
            return "yjcarnavi://"
            
        case .copilot:
            return "copilot://"
        
        case .yandex:
            return "yandexnavi://"
            
        case .cartograph:
            return "cartograph://"
            
        case .organicmaps:
            return "om://"
            
        case .gurumaps:
            return "guru://"
            
        case .myrouteapp:
            return "mra-mobile://x-callback-url/"
            
        case .calimoto:
            return "calimoto://"
            
        case .kurviger:
            return "https://kurviger.de/en"

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
    
        var back_link = ""
        switch self {
        case .appleMaps:
            back_link = ""

        case .googleMaps:
            back_link = "?x-success=wunderlinq://&x-source=WunderLINQ"

        case .scenic:
            back_link = ""

        case .sygic:
            back_link = ""

        case .waze:
            back_link = "?x-success=wunderlinq://&x-source=WunderLINQ"

        case .hereWeGo:
            back_link = ""

        case .mapsMe:
            back_link = "?backurl=wunderlinq://"

        case .osmAnd:
            back_link = ""

        case .tomTomGo:
            back_link = ""

        case .inRoute:
            back_link = "&back_url=wunderlinq://"

        case .mapout:
            back_link = ""
            
        case .yahooJapan:
            back_link = ""
            
        case .copilot:
            back_link = ""
        
        case .yandex:
            back_link = ""
            
        case .cartograph:
            back_link = "&back_url=wunderlinq://"
            
        case .organicmaps:
            back_link = "?backurl=wunderlinq://"
            
        case .gurumaps:
            back_link = "?back_url=wunderlinq://"
            
        case .myrouteapp:
            back_link = "?x-success=wunderlinq://&x-source=WunderLINQ"
            
        case .calimoto:
            back_link = ""
            
        case .kurviger:
            back_link = ""
        }
        
        let url = URL(string: "\(urlScheme)\(back_link)")!
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
    class func navigateTo(destLatitude: Double, destLongitude: Double, destLabel: String?, currentLatitude: Double, currentLongitude: Double) -> Bool {
        var supported = false
        let navAppValue = UserDefaults.standard.integer(forKey: "nav_app_preference")
        guard let navApp = NavigationAppPreference(rawValue: navAppValue) else { return supported }
        
        switch navApp {
        case .appleMaps:
            //Apple Maps
            supported = true
            let coordinates = CLLocationCoordinate2DMake(destLatitude, destLongitude)
            let navPlacemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapitem = MKMapItem(placemark: navPlacemark)
            let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            mapitem.openInMaps(launchOptions: options)
        case .googleMaps:
            //Google Maps
            supported = true
            if let googleMapsURL = URL(string: "\(navApp.urlScheme)?daddr=\(destLatitude),\(destLongitude)&directionsmode=driving&x-success=wunderlinq://?resume=true&x-source=WunderLINQ") {
                if (UIApplication.shared.canOpenURL(googleMapsURL)) {
                    UIApplication.shared.open(googleMapsURL, options: [:], completionHandler: nil)
                }
            }
        case .scenic:
            //Scenic
            supported = true
            let scenic = ScenicAPI()
            scenic.sendToScenicForNavigation(coordinate: CLLocationCoordinate2D(latitude: destLatitude,longitude: destLongitude), name: destLabel ?? "WunderLINQ")
        case .sygic:
            //Sygic
            supported = true
            let urlString = "\(navApp.urlScheme)coordinate|\(destLongitude)|\(destLatitude)|drive"
            
            if let sygicURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(sygicURL)) {
                    UIApplication.shared.open(sygicURL, options: [:], completionHandler: nil)
                }
            }
        case .waze:
            //Waze
            supported = true
            if let wazeURL = URL(string: "\(navApp.urlScheme)?ll=\(destLatitude),\(destLongitude)&navigate=yes") {
                if (UIApplication.shared.canOpenURL(wazeURL)) {
                    UIApplication.shared.open(wazeURL, options: [:], completionHandler: nil)
                }
            }
        case .mapsMe:
            //Maps With Me
            supported = true
            let urlString = "\(navApp.urlScheme)route?sll=\(currentLatitude),\(currentLongitude)&saddr=\(NSLocalizedString("trip_view_waypoint_start_label", comment: ""))&dll=\(destLatitude),\(destLongitude)&daddr=\(destLabel ?? ""))&type=vehicle&backurl=wunderlinq://"
            if let mapsMeURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(mapsMeURL)) {
                    UIApplication.shared.open(mapsMeURL, options: [:], completionHandler: nil)
                }
            }
        case .osmAnd:
            //OsmAnd
            supported = true
            let urlString = "\(navApp.urlScheme)navigate?lat=\(destLatitude)&lon=\(destLongitude)&z=8&title=\(destLabel ?? "")"
            if let mapsMeURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(mapsMeURL)) {
                    UIApplication.shared.open(mapsMeURL, options: [:], completionHandler: nil)
                }
            }
        case .hereWeGo:
            //HERE WeGo
            supported = true
            let urlString = "\(navApp.urlScheme)mylocation/\(destLatitude),\(destLongitude),\(destLabel ?? "")?ref=WunderLINQ&m=d"
            if let hereURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(hereURL)) {
                    UIApplication.shared.open(hereURL, options: [:], completionHandler: nil)
                }
            }
        case .tomTomGo:
            //TomTom GO
            supported = true
            let urlString = "\(navApp.urlScheme)x-callback-url/navigate?destination=\(destLatitude),\(destLongitude)"
            if let uRL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(uRL)) {
                    UIApplication.shared.open(uRL, options: [:], completionHandler: nil)
                }
            }
        case .inRoute:
            //inRoute
            supported = true
            let urlString = "\(navApp.urlScheme)route?geo=\(destLatitude),\(destLongitude)&back_url=wunderlinq://"
            if let uRL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(uRL)) {
                    UIApplication.shared.open(uRL, options: [:], completionHandler: nil)
                }
            }
        case .mapout:
            //Mapout
            supported = true
            let urlString = "\(navApp.urlScheme)longitude=\(destLongitude)&latitude=\(destLatitude)&zoom=15&rotation=0"
            if let uRL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(uRL)) {
                    UIApplication.shared.open(uRL, options: [:], completionHandler: nil)
                }
            }
        case .yahooJapan:
            //Yahoo Japan Car Navigation
            supported = true
            let urlString = "\(navApp.urlScheme)navi/select?lat=\(destLatitude)&lon=\(destLongitude)&name=\(destLabel ?? "")"
            if let uRL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(uRL)) {
                    UIApplication.shared.open(uRL, options: [:], completionHandler: nil)
                }
            }
        case .copilot:
            //CoPilot GPS
            supported = true
            let urlString = "\(navApp.urlScheme)options?type=STOPS&stop=Start||||||\(currentLatitude)|\(currentLongitude)&stop=Stop||||||\(destLatitude)|\(destLongitude)"
            if let uRL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(uRL)) {
                    UIApplication.shared.open(uRL, options: [:], completionHandler: nil)
                }
            }
        case .yandex:
            //Yandex.Navigator
            supported = true
            let urlString = "\(navApp.urlScheme)build_route_on_map?lat_to=\(destLatitude)&lon_to=\(destLongitude)"
            if let uRL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(uRL)) {
                    UIApplication.shared.open(uRL, options: [:], completionHandler: nil)
                }
            }
        case .cartograph:
            //Cartograph Maps
            supported = true
            let urlString = "\(navApp.urlScheme)route?geo=\(destLatitude),\(destLongitude)&back_url=wunderlinq://"
            if let uRL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(uRL)) {
                    UIApplication.shared.open(uRL, options: [:], completionHandler: nil)
                }
            }
        case .organicmaps:
            //Organic Maps
            supported = true
            let urlString = "\(navApp.urlScheme)route?sll=\(currentLatitude),\(currentLongitude)&saddr=\(NSLocalizedString("trip_view_waypoint_start_label", comment: ""))&dll=\(destLatitude),\(destLongitude)&daddr=\(destLabel ?? ""))&type=vehicle&backurl=wunderlinq://"
            if let mapsURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(mapsURL)) {
                    UIApplication.shared.open(mapsURL, options: [:], completionHandler: nil)
                }
            }
        case .gurumaps:
            //Guru Maps
            supported = true
            let urlString = "\(navApp.urlScheme)nav?finish=\(destLatitude),\(destLongitude)&mode=motorcycle&start_navigation=true&back_url=wunderlinq://"
            if let mapsURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(mapsURL)) {
                    UIApplication.shared.open(mapsURL, options: [:], completionHandler: nil)
                }
            }
        case .myrouteapp:
            //Myroute-app
            supported = true
            let urlString = "\(navApp.urlScheme)route?x-success=wunderlinq://&x-source=WunderLINQ&geo=\(destLatitude),\(destLongitude)"
            if let mapsURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(mapsURL)) {
                    UIApplication.shared.open(mapsURL, options: [:], completionHandler: nil)
                }
            }
        case .calimoto:
            //Calimoto
            // Not Supported
            supported = false
        case .kurviger:
            //Kurviger
            supported = true
            //navUrl = "https://kurviger.de/en?point=" + start.getLatitude() + "," + start.getLongitude() + "&padr.0=" +  MyApplication.getContext().getString(R.string.trip_view_waypoint_start_label) + "&point=" + end.getLatitude() + "," + end.getLongitude() + "&padr.1=" + MyApplication.getContext().getString(R.string.trip_view_waypoint_end_label);
            let urlString = "\(navApp.urlScheme)?point=\(currentLatitude),\(currentLongitude)&padr.0=\(NSLocalizedString("trip_view_waypoint_start_label", comment: ""))&point=\(destLatitude),\(destLongitude)&padr.1=\(destLabel ?? "")"
            print("URL: \(urlString)")
            if let mapsURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(mapsURL)) {
                    UIApplication.shared.open(mapsURL, options: [:], completionHandler: nil)
                }
            }
        }
        
        return supported
    }
    
    class func navigateToFuel(currentLatitude: Double, currentLongitude: Double) -> Bool {
        var supported = false
        let navAppValue = UserDefaults.standard.integer(forKey: "nav_app_preference")
        guard let navApp = NavigationAppPreference(rawValue: navAppValue) else { return supported }

        switch navApp {
        case .appleMaps:
            //Apple Maps
            supported = true
            if let appleURL = URL(string: "http://maps.apple.com/?q=fuel+station&sll=\(currentLatitude),\(currentLongitude)&z=10&t=s") {
                if (UIApplication.shared.canOpenURL(appleURL)) {
                    UIApplication.shared.open(appleURL, options: [:], completionHandler: nil)
                }
            }
        case .googleMaps:
            //Google Maps
            supported = true
            let urlString = "\(navApp.urlScheme)?q=fuel+station&directionsmode=driving&x-success=wunderlinq://?resume=true&x-source=WunderLINQ"
            if let googleMapsURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(googleMapsURL)) {
                    UIApplication.shared.open(googleMapsURL, options: [:], completionHandler: nil)
                }
            }
        case .scenic:
            //Scenic
            // Not Supported
            supported = false
        case .sygic:
            //Sygic
            // Not Supported
            supported = false
        case .waze:
            //Waze
            supported = true
            if let wazeURL = URL(string: "https://waze.com/ul?q=fuel&navigate=yes") {
                if (UIApplication.shared.canOpenURL(wazeURL)) {
                    UIApplication.shared.open(wazeURL, options: [:], completionHandler: nil)
                }
            }
        case .mapsMe:
            //Maps.me
            // Not Supported
            supported = false
        case .osmAnd:
            //OsmAnd
            // TODO - Not working
            supported = false
            //let urlString = "\(navApp.urlScheme)navigate_search?start_lat=\(currentLatitude)&start_lon=\(currentLongitude)&dest_search_query=fuel station&search_lat=\(currentLatitude)&search_lon=\(currentLongitude)&profile=motorcycle&force=true&show_search_results=true"
        case .hereWeGo:
            // HERE WeGo
            // Not Supported
            supported = false
        case .tomTomGo:
            // TomTom GO
            // Not Supported
            supported = false
        case .inRoute:
            //inRoute
            // Not Supported
            supported = false
        case .mapout:
            //Mapout
            // Not Supported
            supported = false
        case .yahooJapan:
            //Yahoo Japan Car Navigation
            // Not Supported
            supported = false
        case .copilot:
            //CoPilot
            // Not Supported
            supported = false
        case .yandex:
            //Yandex
            supported = true
            let urlString = "\(navApp.urlScheme)map_search?text=fuel"
            if let uRL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(uRL)) {
                    UIApplication.shared.open(uRL, options: [:], completionHandler: nil)
                }
            }
        case .cartograph:
            //Cartograph Maps
            // Not Supported
            supported = false
        case .organicmaps:
            //Organic Maps
            supported = true
            let urlString = "\(navApp.urlScheme)search?cll=\(currentLatitude),\(currentLongitude)&query=fuel station&backurl=wunderlinq://"
            if let mapsURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(mapsURL)) {
                    UIApplication.shared.open(mapsURL, options: [:], completionHandler: nil)
                }
            }
        case .gurumaps:
            //Guru Maps
            supported = true
            let urlString = "\(navApp.urlScheme)search?q=fuel&coord=\(currentLatitude),\(currentLongitude)&mode=motorcycle&back_url=wunderlinq://"
            if let mapsURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(mapsURL)) {
                    UIApplication.shared.open(mapsURL, options: [:], completionHandler: nil)
                }
            }
        case .myrouteapp:
            //Myroute-app
            // Not Supported
            supported = false
        case .calimoto:
            //Calimoto
            // Not Supported
            supported = false
        case .kurviger:
            //Kurviger
            // Not Supported
            supported = false
        }
        return supported
    }
    
    class func viewWaypoint(destLatitude: Double, destLongitude: Double, destLabel: String?) -> Bool {
        var supported = false
        let navAppValue = UserDefaults.standard.integer(forKey: "nav_app_preference")
        guard let navApp = NavigationAppPreference(rawValue: navAppValue) else { return supported }

        switch navApp {
        case .appleMaps:
            //Apple Maps
            supported = true
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
        case .googleMaps:
            //Google Maps
            supported = true
            let urlString = "\(navApp.urlScheme)?q=\(destLatitude),\(destLongitude)&x-success=wunderlinq://?resume=true&x-source=WunderLINQ"
            if let googleMapsURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(googleMapsURL)) {
                    UIApplication.shared.open(googleMapsURL, options: [:], completionHandler: nil)
                }
            }
        case .scenic:
            //Scenic
            supported = true
            let lat: CLLocationDegrees = destLatitude
            let lon: CLLocationDegrees = destLongitude
            let scenic = ScenicAPI()
            scenic.sendToScenicForNavigation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), name: destLabel ?? "")
        case .sygic:
            //Sygic
            supported = true
            let urlString = "\(navApp.urlScheme)coordinate|\(destLongitude)|\(destLatitude)|show"
            if let sygicURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(sygicURL)) {
                    UIApplication.shared.open(sygicURL, options: [:], completionHandler: nil)
                }
            }
        case .waze:
            //Waze
            supported = true
            if let wazeURL = URL(string: "https://waze.com/ul?ll=\(destLatitude),\(destLongitude)&z=10") {
                if (UIApplication.shared.canOpenURL(wazeURL)) {
                    UIApplication.shared.open(wazeURL, options: [:], completionHandler: nil)
                }
            }
        case .mapsMe:
            //Maps.me
            supported = true
            let urlString = "\(navApp.urlScheme)map?ll=\(destLatitude),\(destLongitude)&n=\(destLabel ?? "")&backurl=wunderlinq://"
            if let mapsMeURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(mapsMeURL)) {
                    UIApplication.shared.open(mapsMeURL, options: [:], completionHandler: nil)
                }
            }
        case .osmAnd:
            //OsmAnd
            supported = true
            let urlString = "\(navApp.urlScheme)lat=\(destLatitude)&lon=\(destLongitude)&z=8&title=\(destLabel ?? "")"
            if let mapsMeURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(mapsMeURL)) {
                    UIApplication.shared.open(mapsMeURL, options: [:], completionHandler: nil)
                }
            }
        case .hereWeGo:
            // HERE WeGo
            supported = true
            let urlString = "\(navApp.urlScheme)\(destLatitude),\(destLongitude),\(destLabel ?? "")?ref=WunderLINQ"
            if let hereURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(hereURL)) {
                    UIApplication.shared.open(hereURL, options: [:], completionHandler: nil)
                }
            }
        case .tomTomGo:
            // TomTom GO
            supported = true
            let urlString = "\(navApp.urlScheme)x-callback-url/navigate?destination=\(destLatitude),\(destLongitude)"
            if let uRL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(uRL)) {
                    UIApplication.shared.open(uRL, options: [:], completionHandler: nil)
                }
            }
        case .inRoute:
            //inRoute
            supported = true
            let urlString = "\(navApp.urlScheme)view?geo=\(destLatitude),\(destLongitude)&back_url=wunderlinq://"
            if let uRL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(uRL)) {
                    UIApplication.shared.open(uRL, options: [:], completionHandler: nil)
                }
            }
        case .mapout:
            //Mapout
            supported = true
            let urlString = "\(navApp.urlScheme)longitude=\(destLongitude)&latitude=\(destLatitude)&zoom=15&rotation=0"
            if let uRL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(uRL)) {
                    UIApplication.shared.open(uRL, options: [:], completionHandler: nil)
                }
            }
        case .yahooJapan:
            //Yahoo Japan Car Navigation
            supported = true
            let urlString = "\(navApp.urlScheme)navi/select?lat=\(destLatitude)&lon=\(destLongitude)&name=\(destLabel ?? "")"
            if let uRL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(uRL)) {
                    UIApplication.shared.open(uRL, options: [:], completionHandler: nil)
                }
            }
        case .copilot:
            //CoPilot
            // Not Supported
            supported = false
        case .yandex:
            //Yandex
            let urlString = "\(navApp.urlScheme)show_point_on_map?lat=\(destLatitude)&lon=\(destLongitude)&zoom=12&no-balloon=0&desc=\(destLabel ?? "")"
            if let uRL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(uRL)) {
                    UIApplication.shared.open(uRL, options: [:], completionHandler: nil)
                }
            }
        case .cartograph:
            //Cartograph Maps
            supported = true
            let urlString = "\(navApp.urlScheme)view?geo=\(destLatitude),\(destLongitude)&back_url=wunderlinq://"
            if let uRL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(uRL)) {
                    UIApplication.shared.open(uRL, options: [:], completionHandler: nil)
                }
            }
        case .organicmaps:
            //Organic Maps
            supported = true
            let urlString = "\(navApp.urlScheme)map?ll=\(destLatitude),\(destLongitude)&n=\(destLabel ?? "")&backurl=wunderlinq://"
            if let mapsURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(mapsURL)) {
                    UIApplication.shared.open(mapsURL, options: [:], completionHandler: nil)
                }
            }
        case .gurumaps:
            //Guru Maps
            supported = true
            let urlString = "\(navApp.urlScheme)show?place=\(destLatitude),\(destLongitude)&back_url=wunderlinq://"
            if let mapsURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(mapsURL)) {
                    UIApplication.shared.open(mapsURL, options: [:], completionHandler: nil)
                }
            }
        case .myrouteapp:
            //Myroute-app
            supported = true
            let urlString = "\(navApp.urlScheme)view?x-success=wunderlinq://&x-source=WunderLINQ&geo=\(destLatitude),\(destLongitude)"
            if let mapsURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(mapsURL)) {
                    UIApplication.shared.open(mapsURL, options: [:], completionHandler: nil)
                }
            }
        case .calimoto:
            //Calimoto
            // Not Supported
            supported = false
        case .kurviger:
            //Kurviger
            supported = true

            let urlString = "\(navApp.urlScheme)?point=\(destLatitude),\(destLongitude)&padr.0=\(destLabel ?? "")"
            if let mapsURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(mapsURL)) {
                    UIApplication.shared.open(mapsURL, options: [:], completionHandler: nil)
                }
            }
        }
        return supported
    }
}
