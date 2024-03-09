//
//  MIDISequence.swift
//  
//
//  Created by Tibor Felföldy on 2024-03-09.
//

import MIDIKitSMF

public struct MIDISequence {
    public struct SequenceEvent {
        public enum Event {
            case midi(MIDIEvent)
        }
        
        public let ticks: UInt32
        public let event: Event
        
        static func midi(_ event: MIDIEvent,
                         at ticks: UInt32) -> SequenceEvent {
            SequenceEvent(ticks: ticks, event: .midi(event))
        }
    }
    
    public var sequence: [SequenceEvent]
}

public extension MIDISequence {
    static func load(from file: MIDIFile) -> MIDISequence {
        let events = file.tracks.flatMap(\.events)
        
        var absoluteTicks: UInt32 = 0
        
        @discardableResult
        func ticks(_ delta: MIDIFileEvent.DeltaTime) -> UInt32 {
            absoluteTicks += delta.ticksValue(using: file.timeBase)
            return absoluteTicks
        }
        
        var sequence = [SequenceEvent]()
        
        for event in events {
            switch event {
            case let .noteOn(delta, event):
                let velocity = Velocity.midiKit(event.velocity)

                let event: MIDIEvent = velocity == 0 ?
                    .noteOff(note: .midiKit(event.note)) :
                    .noteOn(note: .midiKit(event.note),
                            velocity: velocity)

                sequence.append(
                    .midi(event, at: ticks(delta))
                )

            case let .noteOff(delta, event):
                sequence.append(
                    .midi(.noteOff(note: .midiKit(event.note)),
                          at: ticks(delta))
                )

            case let .cc(delta, event):
                let ticks = ticks(delta)
                guard event.controller == .sustainPedal else {
                    break
                }

                let sustain = event.value.midi1Value > 64
                
                // Prevent adding duplicated susstain events.
                if case let .midi(event) = sequence.last?.event,
                   case let .sustain(last) = event,
                   last == sustain {
                    break
                }
                
                sequence.append(
                    .midi(.sustain(sustain), at: ticks)
                )
            default:
                break
            }
        }

        return MIDISequence(sequence: sequence)
    }
}
