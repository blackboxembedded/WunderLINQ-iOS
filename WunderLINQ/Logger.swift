//
//  Logger.swift
//  WunderLINQ
//
//  Created by Keith Conger on 8/21/17.
//  Copyright © 2017 Black Box Embedded, LLC. All rights reserved.
//

import Foundation

class Logger {
    
    static var dateFormat = "yyyyMMdd-hh:mm:ss"
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    class func log(fileName: String, entry: String) {
        // Get the documents folder url
        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        // Destination url for the log file to be saved
        let fileURL = documentDirectory.appendingPathComponent("\(fileName)")
        let formattedEntry = Date().toString() + "," + entry
        do {
            // Write to log
            try formattedEntry.appendLineToURL(fileURL: fileURL as URL)
            
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

extension String {
    func appendLineToURL(fileURL: URL) throws {
        try (self + "\n").appendToURL(fileURL: fileURL)
    }
    
    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
}

extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
}
