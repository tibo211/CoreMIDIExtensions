//
//  Note.swift
//  
//
//  Created by Felföldy Tibor on 2022. 12. 02.
//

import MIDIKit

public typealias Note = UInt8

extension Note {
    static func midiKit(_ note: MIDINote) -> Note {
        note.number.uInt8Value
    }
}
