//
//  MIDICodingStrategy.swift
//  
//
//  Created by Felföldy Tibor on 2022. 12. 03.
//

import CoreMIDI

enum OpCode: UInt8 {
    case note_off = 0b1000
    case note_on =  0b1001
    case control =  0b1011
}

enum ControllEvent: UInt8 {
    case sustain = 64
}

public protocol MIDICodingStrategy {
    var verion: MIDIProtocolID { get }

    /// Converts CoreMIDI Voice Messages to `MIDIEvent`.
    /// - Parameter event: UMP packet
    /// - Returns: Universal `MIDIEvent`
    func decode(event: MIDIEventPacket) -> MIDIEvent?
}

struct MIDICoding_v1: MIDICodingStrategy {
    let verion = MIDIProtocolID._1_0
    
    func decode(event: MIDIEventPacket) -> MIDIEvent? {
        let word = event.words.0

        // MIDI 1.0 Channel Voice Messages
        // MESSAGE TYPE:    4 bits, value 0x2
        // GROUP:           4 bits
        // OPTCODE:         4 bits
        // CHANNEL:         4 bits
        // NOTE NUMBER:     8 bits
        // VELOCITY:        8 bits
        
        let opcode = UInt8(word >> 20 & 0xF)
        // let channel = word >> 16 & 0xF
        let data = UInt8(word >> 8 & 0xFF)
        let velocity = Velocity.midi_v1(UInt8(word & 0xFF))
        
        switch OpCode(rawValue: opcode) {
        case .note_off:
            return MIDIEvent.noteOff(note: data)
        case .note_on:
            // For some devices velocity 0 is note off.
            if velocity == 0 {
                return MIDIEvent.noteOff(note: data)
            } else {
                return MIDIEvent.noteOn(note: data, velocity: velocity)
            }
        case .control:
            switch ControllEvent(rawValue: data) {
            case .sustain:
                return MIDIEvent.sustain(velocity >= 0.5)
            default:
                break
            }
        default:
            break
        }

        Log.warning("Unhandled midi input (opcode: \(String(binary: opcode, size: 4)), data: \(String(binary: word & 0xFFFF, size: 16))")
        
        return nil
    }
}
