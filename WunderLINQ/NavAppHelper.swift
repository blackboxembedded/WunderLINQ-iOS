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

class NavAppHelper {
    
    class func open() {
        let navApp = UserDefaults.standard.integer(forKey: "nav_app_preference")
        switch (navApp){
        case 0:
            //Apple Maps
            let map = MKMapItem()
            map.openInMaps(launchOptions: nil)
        case 1:
            //Google Maps
            //https://developers.google.com/maps/documentation/urls/ios-urlscheme
            if let googleMapsURL = URL(string: "comgooglemaps-x-callback://?x-success=wunderlinq://&x-source=WunderLINQ") {
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
            let scenic = ScenicAPI()
            scenic.sendToScenicForNavigation(coordinate: CLLocationCoordinate2D(latitude: 0,longitude: 0), name: "WunderLINQ")
        case 3:
            //Sygic
            //https://www.sygic.com/developers/professional-navigation-sdk/ios/custom-url
            let urlString = "com.sygic.aura://"
            
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
            if let wazeURL = URL(string: "waze://") {
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
            if let mapsMeURL = URL(string: "mapsme://?backurl=wunderlinq://") {
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
            let urlString = "osmandmaps://"
            if let osmAndURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(osmAndURL)) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(osmAndURL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(osmAndURL as URL)
                    }
                }
            }
        case 7:
            // Here We Go
            // https://developer.here.com/documentation/mobility-on-demand-toolkit/dev_guide/topics/navigation.html
            // here-route://mylocation/37.870090,-122.268150,Downtown%20Berkeley?ref=WunderLINQ&m=d
            let urlString = "here-route://"
            if let uRL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(uRL)) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(uRL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(uRL as URL)
                    }
                }
            }
        case 8:
            // TomTom GO
            // https://discussions.tomtom.com/en/discussion/1118783/url-schemes-for-go-navigation-ios/
            // tomtomgo://x-callback-url/navigate?destination=52.371183,4.892504
            let urlString = "tomtomgo://"
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
            let urlString = "inroute://"
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
            let map = MKMapItem()
            map.openInMaps(launchOptions: nil)
        }
    }
    
    class func navigateTo(destLatitude: Double, destLongitude: Double, destLabel: String?, currentLatitude: Double, currentLongitude: Double) {
        let navApp = UserDefaults.standard.integer(forKey: "nav_app_preference")
        switch (navApp){
        case 0:
            //Apple Maps
            let coordinates = CLLocationCoordinate2DMake(destLatitude, destLongitude)
            let navPlacemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapitem = MKMapItem(placemark: navPlacemark)
            let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            mapitem.openInMaps(launchOptions: options)
        case 1:
            //Google Maps
            //googlemaps://
            if let googleMapsURL = URL(string: "comgooglemaps-x-callback://?daddr=\(destLatitude),\(destLongitude)&directionsmode=driving&x-success=wunderlinq://?resume=true&x-source=WunderLINQ") {
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
            let scenic = ScenicAPI()
            scenic.sendToScenicForNavigation(coordinate: CLLocationCoordinate2D(latitude: destLatitude,longitude: destLongitude), name: destLabel ?? "WunderLINQ")
        case 3:
            //Sygic
            //https://www.sygic.com/developers/professional-navigation-sdk/ios/custom-url
            let urlString = "com.sygic.aura://coordinate|\(destLongitude)|\(destLatitude)|drive"
            
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
            //waze://?ll=[lat],[lon]&z=10
            if let wazeURL = URL(string: "waze://?ll=\(destLatitude),\(destLongitude)&navigate=yes") {
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
            let urlString = "mapsme://route?sll=\(currentLatitude),\(currentLongitude)&saddr=\(NSLocalizedString("trip_view_waypoint_start_label", comment: ""))&dll=\(destLatitude),\(destLongitude)&daddr=\(destLabel ?? ""))&type=vehicle&backurl=wunderlinq://"
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
            let urlString = "osmandmaps://navigate?lat=\(destLatitude)&lon=\(destLongitude)&z=8&title=\(destLabel ?? "")"
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
            // Here We Go
            // https://developer.here.com/documentation/mobility-on-demand-toolkit/dev_guide/topics/navigation.html
            // here-route://mylocation/37.870090,-122.268150,Downtown%20Berkeley?ref=WunderLINQ&m=d
            let urlString = "here-route://mylocation/\(destLatitude),\(destLongitude),\(destLabel ?? "")?ref=WunderLINQ&m=d"
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
            let urlString = "inroute://coordinates?action=opt&loc=Start/\(currentLatitude)/\(currentLongitude)&loc=\(destLabel ?? "")/\(destLatitude)/\(destLongitude)"
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
            let coordinates = CLLocationCoordinate2DMake(destLatitude, destLongitude)
            let navPlacemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapitem = MKMapItem(placemark: navPlacemark)
            let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            mapitem.openInMaps(launchOptions: options)
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
        }
    }
}
