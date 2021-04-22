//
//  GPXRoute.swift
//  GPXKit
//
//  Created by Vincent on 8/12/18.
//  

import Foundation

/**
 Value type that represents a route, or `rteType` in GPX v1.1 schema.
 
 The route can represent the planned route of a specific trip.
 */
public final class GPXRoute: GPXElement, Codable, GPXRouteType {
    
    /// For Codable use
    private enum CodingKeys: String, CodingKey {
        case name
        case comment = "cmt"
        case desc
        case source = "src"
        case links = "link"
        case type
        case extensions
    }
    
    /// Name of the route.
    public var name: String?
    
    /// Additional comment of the route.
    public var comment: String?
    
    /// Description of the route.
    public var desc: String?
    
    /// Source of the route.
    public var source: String?
    
    /// A value type for link properties (see `GPXLink`)
    ///
    /// Intended for additional information about current route through a web link.
    @available(*, deprecated, message: "CoreGPX now support multiple links.", renamed: "links.first")
    public var link: GPXLink? {
        return links.first
    }
    
    /// A value type for link properties (see `GPXLink`)
    ///
    /// Intended for additional information about current route through web links.
    public var links = [GPXLink]()
    
    /// Type of route.
    public var type: String?
    
    /// Extensions
    public var extensions: GPXExtensions?
    
    /// Route points in the route.
    ///
    /// All route points joined represents a route.
    @available(*, deprecated, renamed: "points")
    public var routepoints: [GPXRoutePoint] {
        return points
    }
    
    /// Route points in the route.
    ///
    /// All route points joined represents a route.
    public var points = [GPXRoutePoint]()
    
    /// Number of route (possibly a tag for the route)
    public var number: Int?
    
    // MARK:- Instance
    
    /// Default initializer.
    public required init() {
        super.init()
    }
    
    /// Inits native element from raw parser value
    ///
    /// - Parameters:
    ///     - raw: Raw element expected from parser
    init(raw: GPXRawElement) {
        for child in raw.children {
            switch child.name {
            case "link":        self.links.append(GPXLink(raw: child))
            case "rtept":       self.points.append(GPXRoutePoint(raw: child))
            case "name":        self.name = child.text
            case "cmt":         self.comment = child.text
            case "desc":        self.desc = child.text
            case "src":         self.source = child.text
            case "type":        self.type = child.text
            case "number":      self.number = Convert.toInt(from: child.text)
            case "extensions":  self.extensions = GPXExtensions(raw: child)
            default: continue
            }
        }
    }
    
    // MARK: Public Methods
    
    /// Creates a `GPXLink` which is added to the route and also returned.
    ///
    /// Not recommended for use. Init `GPXRoutePoint` manually, then adding it to route, instead.
    func newLink(withHref href: String) -> GPXLink {
        let link: GPXLink = GPXLink(withHref: href)
        self.links.append(link)
        return link
    }
    
    /// Creates a `GPXRoutePoint` which is added to the route and also returned.
    ///
    /// Not recommended for use. Init `GPXRoutePoint` manually, then adding it to route, instead.
    func newRoutePointWith(latitude: Double, longitude: Double) -> GPXRoutePoint {
        let routepoint = GPXRoutePoint(latitude: latitude, longitude: longitude)

        self.add(routepoint: routepoint)
        
        return routepoint
    }
    
    /// Adds a singular route point to the route.
    func add(routepoint: GPXRoutePoint?) {
        if let validPoint = routepoint {
            points.append(validPoint)
        }
    }
    
    /// Adds an array of route points to the route.
    func add(routepoints: [GPXRoutePoint]) {
        self.points.append(contentsOf: routepoints)
    }
    
    /// Removes a route point from the route.
    func remove(routepoint: GPXRoutePoint) {
        let contains = points.contains(routepoint)
        if contains == true {
            if let index = points.firstIndex(of: routepoint) {
                points.remove(at: index)
            }
        }
        
    }
    
    // MARK:- Tag
    
    override func tagName() -> String {
        return "rte"
    }
    
    // MARK:- GPX
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        
        self.addProperty(forValue: name, gpx: gpx, tagName: "name", indentationLevel: indentationLevel)
        self.addProperty(forValue: comment, gpx: gpx, tagName: "comment", indentationLevel: indentationLevel)
        self.addProperty(forValue: desc, gpx: gpx, tagName: "desc", indentationLevel: indentationLevel)
        self.addProperty(forValue: source, gpx: gpx, tagName: "src", indentationLevel: indentationLevel)
        
        for link in links {
           link.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        self.addProperty(forIntegerValue: number, gpx: gpx, tagName: "number", indentationLevel: indentationLevel)
        self.addProperty(forValue: type, gpx: gpx, tagName: "type", indentationLevel: indentationLevel)
        
        if self.extensions != nil {
            self.extensions?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        for routepoint in points {
            routepoint.gpx(gpx, indentationLevel: indentationLevel)
        }
    }
}
