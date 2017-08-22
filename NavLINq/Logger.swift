//
//  Logger.swift
//  NavLINq
//
//  Created by Keith Conger on 8/21/17.
//  Copyright © 2017 Keith Conger. All rights reserved.
//

import Foundation

class Logger {
    
    static var dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    class func log(fileName: String, entry: String) {

        print("\(sourceFileName(filePath: fileName)),\(Date().toString()),\(entry)")
        
        // get the documents folder url
        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        // create the destination url for the text file to be saved
        let fileURL = documentDirectory.appendingPathComponent("\(fileName)")
        let formattedEntry = Date().toString() + "," + entry
        do {
            // writing to disk
            try formattedEntry.write(to: fileURL, atomically: false, encoding: .utf8)
            
        } catch {
            print("error writing to url:", fileURL, error)
        }

    }
    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}

internal extension Date {
    func toString() -> String {
        return Logger.dateFormatter.string(from: self as Date)
    }
}
