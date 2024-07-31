//
//  Log.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 01/06/24.
//

import Foundation

enum Log {
    static func d(_ message: String, function: String = #function, file: String = #file, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        print("DEBUG: [\(fileName):\(line)] \(function) - \(message)")
    }
    
    static func i(_ message: String, function: String = #function, file: String = #file, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        print("INFO: [\(fileName):\(line)] \(function) - \(message)")
    }
    
    static func w(_ message: String, function: String = #function, file: String = #file, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        print("WARN: [\(fileName):\(line)] \(function) - \(message)")
    }
    
    static func e(_ message: String, function: String = #function, file: String = #file, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        print("ERROR: [\(fileName):\(line)] \(function) - \(message)")
    }
}
