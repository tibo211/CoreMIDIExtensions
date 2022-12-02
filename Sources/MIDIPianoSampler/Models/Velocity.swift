//
//  Velocity.swift
//  
//
//  Created by Felföldy Tibor on 2022. 12. 02.
//

import Foundation

public typealias Velocity = Float

extension Velocity {
    /// In a MIDI 1.0 event the value of the velocity is represented in 7 bit.
    ///
    /// This value is converted to float to make it easier to do operations on it.
    /// - Parameter value: 0 - 127
    /// - Returns: FLoat value between 0 - 1
    static func midi_v1(_ value: UInt8) -> Velocity {
        Float(value) / Float(127)
    }
    
    var midi_v1: UInt8 {
        UInt8(self * 127)
    }
}
