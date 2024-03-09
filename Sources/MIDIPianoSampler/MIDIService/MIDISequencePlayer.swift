//
//  MIDISequencePlayer.swift
//
//
//  Created by Tibor Felföldy on 2024-03-09.
//

import Foundation
import Combine
import MIDIKitSMF

public final class MIDISequencePlayer: MIDIService {
    public let name = "MIDI Sequence Player"
    public let output: AnyPublisher<MIDIEvent, Never>
    public private(set) var isPlaying = false

    public var tempo: Double = 60 {
        didSet { setTimer() }
    }

    private var midiSequence: MIDISequence
    private var eventIndex = 0
    private var currentTimeInTicks: UInt32 = 0
    private var timer: Timer?
    private let playEventSubject = PassthroughSubject<MIDIEvent, Never>()

    public init(url: URL) throws {
        let file = try MIDIFile(midiFile: url)
        midiSequence = try .load(from: file)
        output = playEventSubject.eraseToAnyPublisher()
    }
    
    public init(sequence: MIDISequence) {
        midiSequence = sequence
        output = playEventSubject.eraseToAnyPublisher()
    }

    public func start() {
        guard eventIndex < midiSequence.sequence.count else {
            isPlaying = false
            return
        }
        
        setTimer()
    }

    public func stop() {
        timer?.invalidate()
        timer = nil
        eventIndex = 0
        currentTimeInTicks = 0
    }
    
    private func setTimer() {
        timer?.invalidate()
        
        let tickInterval = 60.0 / (tempo * Double(midiSequence.ticksPerQuarterNote))
        
        timer = Timer.scheduledTimer(
            timeInterval: tickInterval,
            target: self, selector: #selector(processEvents),
            userInfo: nil,
            repeats: true
        )
    }

    @objc private func processEvents() {
        while midiSequence.sequence[eventIndex].ticks <= currentTimeInTicks {
            let event = midiSequence.sequence[eventIndex].event
            
            switch event {
            case let .midi(midiEvent):
                playEventSubject.send(midiEvent)
            case .end:
                stop()
                return
            }
            
            eventIndex += 1
        }
        
        currentTimeInTicks += 1
    }
}
