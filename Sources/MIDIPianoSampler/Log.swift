//
//  Log.swift
//  
//
//  Created by Felföldy Tibor on 2022. 12. 02..
//

import Foundation

func log(message: @autoclosure () -> String) {
    #if DEBUG
    print("🎹 - \(message())")
    #endif
}
