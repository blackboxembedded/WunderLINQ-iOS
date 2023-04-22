# WunderLINQ iOS App

The WunderLINQ app is for use with the [WunderLINQ Hardware](https://www.wunderlinq.com)

The WunderLINQ is a combination of Plug-and-Play hardware that snaps into your existing BMW Motorcycle 
Navigation Prep and a companion app for your Android or iOS phone or tablet.  Together they allow you 
to control your mobile device and other connected devices like GoPros from your handlebar wheel.  
If your motorcycle also has the On Board Computer Pro option the WunderLINQ can also receive and 
decode performance and fault data.

<a href="https://itunes.apple.com/us/app/wunderlinq/id1410462734?ls=1&mt=8" target="_blank">
<img src="https://blackboxembedded.github.io/WunderLINQ-Documentation/en/images-localized/badge_store_appstore.png" alt="Get it on AppStore" height="60"/></a>

<p>
<a href="https://weblate.blackboxembedded.com/engage/wunderlinq/">
<img src="https://weblate.blackboxembedded.com/widgets/wunderlinq/-/wunderlinq-ios/svg-badge.svg" alt="Translation status" />
</a>
</p>

## Build Instructions
1. Clone the project and open the workspace in Xcode

2. Create a file called WunderLINQ/Secrets.swift with your own Google Maps API key and Spotify app ID it, like so:
```swift
struct Secrets {
    static let spotify_app_id = "YOUR_APP_ID_HERE"
    static let google_maps_api_key = "YOUR_API_KEY_HERE"
}
```
3. Build and Run
