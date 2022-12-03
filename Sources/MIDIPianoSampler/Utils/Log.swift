//
//  Log.swift
//  
//
//  Created by Felföldy Tibor on 2022. 12. 02..
//

enum Log {
    static func info(_ message: @autoclosure () -> String) {
        #if DEBUG
        print("🎹 - \(message())")
        #endif
    }
    
    static func warning(_ message: @autoclosure () -> String) {
        #if DEBUG
        print("⚠️ - \(message())")
        #endif
    }
    
    static func error(_ message: @autoclosure () -> String) {
        #if DEBUG
        print("❗️ - \(message())")
        #endif
    }
}
