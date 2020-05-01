# WunderLINQ iOS App

The WunderLINQ app is for use with the [WunderLINQ Hardware](https://www.wunderlinq.com)

The WunderLINQ is a combination of Plug-and-Play hardware that snaps into your existing BMW Motorcycle 
Navigation Prep and a companion app for your Android or iOS phone or tablet.  Together they allow you 
to control your mobile device and other connected devices like GoPros from your handlebar wheel.  
If your motorcycle also has the On Board Computer Pro option the WunderLINQ can also receive and 
decode performance and fault data.

## Build Instructions
1. Clone the project and open in Xcode

2. Create an xml resource file called WunderLINQ/Secrets.swift with your own Google Maps API key and Spotify app ID it, like so:
```swift
struct Secrets {
    static let spotify_app_id = "***REMOVED***"
    static let google_maps_api_key = "***REMOVED***"
}
```
3. Build and Run
