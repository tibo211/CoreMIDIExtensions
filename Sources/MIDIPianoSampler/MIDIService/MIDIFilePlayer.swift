//
//  MIDIFilePlayer.swift
//
//
//  Created by Tibor Felföldy on 2024-03-04.
//

import Foundation
import MIDIKitSMF
import Combine

struct TimedMIDIEvent {
    let ticks: UInt32
    let event: MIDIEvent
}

public final class MIDIFilePlayer: MIDIService {
    public let name = "MIDI File Player"
    public let output: AnyPublisher<MIDIEvent, Never>
    
    public var tempo: Double = 60
    public private(set) var isPlaying = false
    
    private let file: MIDIFile
    private let events: [TimedMIDIEvent]
    private var eventIndex = 0
    private let playEventSubject = PassthroughSubject<MIDIEvent, Never>()
    
    init(file: URL) throws {
        let file = try MIDIFile(midiFile: file)
        self.file = file
        
        events = file.tracks.flatMap(\.events)
            .compactMap { fileEvent -> TimedMIDIEvent? in
                fileEvent.toEvent(file: file)
            }
        
        output = playEventSubject.eraseToAnyPublisher()
    }
    
    public func togglePlay() {
        isPlaying.toggle()
        if isPlaying {
            scheduleEvent()
        }
    }
    
    private func scheduleEvent() {
        guard isPlaying else { return }

        let event = events[eventIndex]
        let seconds = ticksToSeconds(ticks: event.ticks)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [self] in
            playEventSubject.send(event.event)
            
            eventIndex = (eventIndex + 1) % events.count
            scheduleEvent()
        }
    }
    
    private func ticksToSeconds(ticks: UInt32) -> Double {
        switch file.timeBase {
        case let .musical(ticksPerQuarterNote):
            return (Double(ticks) / Double(ticksPerQuarterNote)) * (60.0 / Double(tempo))
        case let .timecode(smpteFormat, ticksPerFrame):
            return (Double(ticks) / Double(ticksPerFrame)) * (1.0 / smpteFormat.fps)
        }
    }
}

extension MIDIFileEvent {
    func toEvent(file: MIDIFile) -> TimedMIDIEvent? {
        switch self {
        case let .noteOn(delta, event):
            let ticks = delta.ticksValue(using: file.timeBase)
            
            if event.velocity.midi1Value == 0 {
                return TimedMIDIEvent(
                    ticks: ticks,
                    event: .noteOff(note: event.note.value)
                )
            }
            
            return TimedMIDIEvent(
                ticks: ticks,
                event: .noteOn(
                    note: event.note.value,
                    velocity: .midi_v1(
                        event.velocity.midi1Value.uInt8Value
                    )
                )
            )
            
        case let .noteOff(delta, event):
            let ticks = delta.ticksValue(using: file.timeBase)

            return TimedMIDIEvent(
                ticks: ticks,
                event: .noteOff(note: event.note.value)
            )

        case let .cc(delta, event):
            let ticks = delta.ticksValue(using: file.timeBase)
            
            guard event.controller == .sustainPedal else {
                fallthrough
            }
            
            return TimedMIDIEvent(ticks: ticks, event: .sustain(event.value.midi1Value > 64))
        default:
            return nil
        }
    }
}

extension MIDIFile.FrameRate {
    var fps: Double {
        switch self {
        case .fps24: 24
        case .fps25: 25
        case .fps29_97d: 29.97
        case .fps30: 30
        }
    }
}

extension MIDINote {
    var value: Note {
        number.uInt8Value
    }
}
