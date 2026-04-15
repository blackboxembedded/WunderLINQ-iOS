import UIKit
import GoogleMaps

private struct WeatherMapsResponse: Decodable {
   let host: String
   let radar: RadarSection
}

private struct RadarSection: Decodable {
   let past: [RadarFrame]
}

private struct RadarFrame: Decodable, Equatable {
   let time: Int
   let path: String
}

class WeatherMapViewController: UIViewController, GMSMapViewDelegate {

   private static let rainViewerAPIURL = "https://api.rainviewer.com/public/weather-maps.json"
   private static let defaultRainHost = "https://tilecache.rainviewer.com"

   private static let radarTileSize = 256
   private static let radarColorScheme = 2
   private static let radarOptions = "1_1"
   private static let radarMaxZoom = 7

   private static let uiUpdateDelay: TimeInterval = 10.0
   private static let frameRefreshInterval: TimeInterval = 5 * 60.0
   private static let animationDuration: TimeInterval = 60.0
   private static let animationRestartDelay: TimeInterval = 5.0

   let motorcycleData = MotorcycleData.shared
   let faults = Faults.shared

   @IBOutlet weak var mapView: GMSMapView!
   @IBOutlet weak var dateLabel: UILabel!

   var faultsBtn: UIButton!
   var faultsButton: UIBarButtonItem!

   private let marker = GMSMarker()
   private var radarTileLayer: GMSURLTileLayer?

   private var displayLink: CADisplayLink?
   private var animationRestartTimer: Timer?
   private var statusTimer: Timer?
   private var frameRefreshTimer: Timer?

   private var animationStartTime: CFTimeInterval?
   private var allowAnimationRestart = true

   private var currentZoom = WeatherMapViewController.radarMaxZoom

   private var rainHost = WeatherMapViewController.defaultRainHost
   private var radarFrames: [RadarFrame] = []
   private var currentFrameIndex = -1

   private lazy var radarDateFormatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateFormat = "EEE MMM dd HH:mm:ss z yyyy"
      return formatter
   }()

   private var currentRadarFrame: RadarFrame? {
      guard radarFrames.indices.contains(currentFrameIndex) else {
         return nil
      }
      return radarFrames[currentFrameIndex]
   }

   override var keyCommands: [UIKeyCommand]? {
      let commands = [
         UIKeyCommand(input: "\u{d}", modifierFlags: [], action: #selector(centerMap)),
         UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(zoomIn)),
         UIKeyCommand(input: "+", modifierFlags: [], action: #selector(zoomIn)),
         UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(zoomOut)),
         UIKeyCommand(input: "-", modifierFlags: [], action: #selector(zoomOut)),
         UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: [], action: #selector(leftScreen))
      ]

      if #available(iOS 15, *) {
         commands.forEach { $0.wantsPriorityOverSystemBehavior = true }
      }

      return commands
   }

   override func viewDidLoad() {
      super.viewDidLoad()

      setupNavigationItems()

      mapView.delegate = self
      mapView.mapType = .normal
      mapView.clear()

      setupRadarOverlay()
      updateMarkerAndCamera(centerWithZoom: true)

      dateLabel.text = "Loading radar..."
   }

   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      allowAnimationRestart = true
      startRuntimeTasks()
   }

   override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      allowAnimationRestart = false
      stopRuntimeTasks()
   }

   func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
      currentZoom = Int(position.zoom.rounded())
   }

   @objc func centerMap() {
      SoundManager().playSoundEffect("enter")
      guard let lat = motorcycleData.location?.coordinate.latitude,
            let lon = motorcycleData.location?.coordinate.longitude else {
         return
      }

      let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: Float(currentZoom))
      mapView.camera = camera
      mapView.animate(to: camera)
   }

   @objc func zoomIn() {
      SoundManager().playSoundEffect("directional")

      if currentZoom < WeatherMapViewController.radarMaxZoom {
         currentZoom += 1
         centerMap()
      }
   }

   @objc func zoomOut() {
      SoundManager().playSoundEffect("directional")

      if currentZoom > 3 {
         currentZoom -= 1
         centerMap()
      }
   }

   @objc func leftScreen() {
      SoundManager().playSoundEffect("directional")
      _ = navigationController?.popViewController(animated: true)
   }

   private func setupNavigationItems() {
      let backBtn = UIButton()
      backBtn.setImage(UIImage(named: "Left")?.withRenderingMode(.alwaysTemplate), for: .normal)
      backBtn.tintColor = UIColor(named: "imageTint")
      backBtn.addTarget(self, action: #selector(leftScreen), for: .touchUpInside)

      let backButton = UIBarButtonItem(customView: backBtn)
      backButton.customView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
      backButton.customView?.heightAnchor.constraint(equalToConstant: 30).isActive = true

      faultsBtn = UIButton(type: .custom)
      let faultsImage = UIImage(named: "Alert")?.withRenderingMode(.alwaysTemplate)
      faultsBtn.setImage(faultsImage, for: .normal)
      faultsBtn.tintColor = UIColor.clear
      faultsBtn.accessibilityIgnoresInvertColors = true
      faultsBtn.addTarget(self, action: #selector(faultsButtonTapped), for: .touchUpInside)

      faultsButton = UIBarButtonItem(customView: faultsBtn)
      faultsButton.accessibilityRespondsToUserInteraction = false
      faultsButton.isAccessibilityElement = false
      faultsButton.customView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
      faultsButton.customView?.heightAnchor.constraint(equalToConstant: 30).isActive = true

      navigationItem.title = NSLocalizedString("weathermap_title", comment: "")
      navigationItem.leftBarButtonItems = [backButton, faultsButton]

      updateFaultButton()
   }

   private func setupRadarOverlay() {
      radarTileLayer?.map = nil

      let urls: GMSTileURLConstructor = { [weak self] x, y, zoom in
         guard let self = self,
               let frame = self.currentRadarFrame else {
            return nil
         }

         let radarZoom = min(Int(zoom), WeatherMapViewController.radarMaxZoom)
         let urlString = "\(self.rainHost)\(frame.path)/\(WeatherMapViewController.radarTileSize)/\(radarZoom)/\(x)/\(y)/\(WeatherMapViewController.radarColorScheme)/\(WeatherMapViewController.radarOptions).png"
         return URL(string: urlString)
      }

      let layer = GMSURLTileLayer(urlConstructor: urls)
      layer.zIndex = 100
      layer.map = mapView
      radarTileLayer = layer
   }

   private func startRuntimeTasks() {
      stopRuntimeTasks()

      updateFaultButton()
      updateMarkerAndCamera(centerWithZoom: false)
      loadRainViewerFrames()

      statusTimer = makeRepeatingTimer(interval: WeatherMapViewController.uiUpdateDelay) { [weak self] in
         guard let self = self else { return }
         self.updateFaultButton()
         self.updateMarkerAndCamera(centerWithZoom: false)
      }

      frameRefreshTimer = makeRepeatingTimer(interval: WeatherMapViewController.frameRefreshInterval) { [weak self] in
         self?.loadRainViewerFrames()
      }
   }

   private func stopRuntimeTasks() {
      statusTimer?.invalidate()
      statusTimer = nil

      frameRefreshTimer?.invalidate()
      frameRefreshTimer = nil

      animationRestartTimer?.invalidate()
      animationRestartTimer = nil

      displayLink?.invalidate()
      displayLink = nil

      animationStartTime = nil
   }

   private func makeRepeatingTimer(interval: TimeInterval, action: @escaping () -> Void) -> Timer {
      let timer = Timer(timeInterval: interval, repeats: true) { _ in
         action()
      }
      RunLoop.main.add(timer, forMode: .common)
      return timer
   }

   private func makeOneShotTimer(interval: TimeInterval, action: @escaping () -> Void) -> Timer {
      let timer = Timer(timeInterval: interval, repeats: false) { _ in
         action()
      }
      RunLoop.main.add(timer, forMode: .common)
      return timer
   }

   private func loadRainViewerFrames() {
      guard let url = URL(string: WeatherMapViewController.rainViewerAPIURL) else {
         return
      }

      var request = URLRequest(url: url)
      request.timeoutInterval = 10
      request.cachePolicy = .reloadIgnoringLocalCacheData
      request.setValue("application/json", forHTTPHeaderField: "Accept")

      URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
         guard let self = self else { return }

         if let error = error {
            NSLog("WeatherMapViewController: RainViewer fetch error: \(error.localizedDescription)")
            return
         }

         guard let httpResponse = response as? HTTPURLResponse else {
            NSLog("WeatherMapViewController: Invalid RainViewer response")
            return
         }

         guard httpResponse.statusCode == 200 else {
            NSLog("WeatherMapViewController: RainViewer HTTP \(httpResponse.statusCode)")
            return
         }

         guard let data = data else {
            NSLog("WeatherMapViewController: RainViewer response missing data")
            return
         }

         do {
            let decoded = try JSONDecoder().decode(WeatherMapsResponse.self, from: data)

            DispatchQueue.main.async {
               let changed = self.framesChanged(newHost: decoded.host, newFrames: decoded.radar.past)

               self.rainHost = decoded.host
               self.radarFrames = decoded.radar.past

               guard !self.radarFrames.isEmpty else {
                  self.currentFrameIndex = -1
                  self.dateLabel.text = "No radar frames available"
                  self.radarTileLayer?.clearTileCache()
                  return
               }

               if self.currentFrameIndex < 0 || self.currentFrameIndex >= self.radarFrames.count || changed {
                  self.applyFrameIndex(self.radarFrames.count - 1, clearCache: true)
               } else {
                  self.updateDisplayedFrameTime()
               }

               if changed {
                  self.radarTileLayer?.clearTileCache()
               }

               if self.allowAnimationRestart,
                  self.radarFrames.count > 1,
                  self.displayLink == nil {
                  self.scheduleAnimationRestart(WeatherMapViewController.animationRestartDelay)
               }
            }
         } catch {
            NSLog("WeatherMapViewController: RainViewer decode error: \(error.localizedDescription)")
         }
      }.resume()
   }

   private func framesChanged(newHost: String, newFrames: [RadarFrame]) -> Bool {
      if rainHost != newHost {
         return true
      }

      if radarFrames.count != newFrames.count {
         return true
      }

      for index in radarFrames.indices {
         if radarFrames[index] != newFrames[index] {
            return true
         }
      }

      return false
   }

   private func applyFrameIndex(_ frameIndex: Int, clearCache: Bool) {
      guard radarFrames.indices.contains(frameIndex) else {
         return
      }

      currentFrameIndex = frameIndex
      updateDisplayedFrameTime()

      if clearCache {
         radarTileLayer?.clearTileCache()
      }
   }

   private func updateDisplayedFrameTime() {
      guard let frame = currentRadarFrame else {
         return
      }

      let date = Date(timeIntervalSince1970: TimeInterval(frame.time))
      dateLabel.text = radarDateFormatter.string(from: date)
      NSLog("WeatherMapViewController: Displaying radar frame \(date)")
   }

   private func scheduleAnimationRestart(_ delay: TimeInterval) {
      animationRestartTimer?.invalidate()
      animationRestartTimer = makeOneShotTimer(interval: delay) { [weak self] in
         guard let self = self else { return }

         if !self.allowAnimationRestart {
            return
         }

         if self.radarFrames.count > 1 && self.displayLink == nil {
            self.beginAnimationCycle()
         }
      }
   }

   private func beginAnimationCycle() {
      displayLink?.invalidate()
      displayLink = nil

      guard radarFrames.count > 1 else {
         return
      }

      animationStartTime = CACurrentMediaTime()

      let link = CADisplayLink(target: self, selector: #selector(updateAnimation))
      link.add(to: .main, forMode: .common)
      displayLink = link
   }

   @objc private func updateAnimation() {
      guard let animationStartTime = animationStartTime, !radarFrames.isEmpty else {
         return
      }

      let elapsed = CACurrentMediaTime() - animationStartTime
      let progress = min(1.0, elapsed / WeatherMapViewController.animationDuration)

      let lastIndex = radarFrames.count - 1
      let newIndex = min(lastIndex, max(0, Int(round(progress * Double(lastIndex)))))

      if newIndex != currentFrameIndex {
         applyFrameIndex(newIndex, clearCache: true)
      }

      if progress >= 1.0 {
         displayLink?.invalidate()
         displayLink = nil
         self.animationStartTime = nil

         if allowAnimationRestart {
            scheduleAnimationRestart(WeatherMapViewController.animationRestartDelay)
         }
      }
   }

   private func updateFaultButton() {
      if faults.getallActiveDesc().isEmpty {
         faultsBtn.tintColor = UIColor.clear
         faultsButton.isEnabled = false
      } else {
         faultsBtn.tintColor = UIColor(named: "motorrad_red")
         faultsButton.isEnabled = true
      }
   }

   private func updateMarkerAndCamera(centerWithZoom: Bool) {
      guard let lat = motorcycleData.location?.coordinate.latitude,
            let lon = motorcycleData.location?.coordinate.longitude else {
         return
      }

      let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)

      marker.position = coordinate
      marker.map = mapView

      if centerWithZoom {
         let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: Float(currentZoom))
         mapView.camera = camera
      } else {
         let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: mapView.camera.zoom)
         mapView.camera = camera
      }
   }

   @objc func faultsButtonTapped() {
      let viewController = storyboard?.instantiateViewController(withIdentifier: "FaultsTableViewController") as! FaultsTableViewController
      navigationController?.pushViewController(viewController, animated: true)
   }
}
