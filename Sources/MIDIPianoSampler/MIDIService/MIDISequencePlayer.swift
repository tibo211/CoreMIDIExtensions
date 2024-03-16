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
    
    public let beatPublisher = PassthroughSubject<Void, Never>()

    public var tempo: Double = 60 {
        didSet { setTimer() }
    }

    private var midiSequence: MIDISequence
    private var eventIndex = 0
    private var currentTimeInTicks: UInt32 = 0
    private var timer: DispatchSourceTimer?
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
        timer?.cancel()
        timer = nil
        eventIndex = 0
        currentTimeInTicks = 0
    }
    
    private func setTimer() {
        timer?.cancel()
        
        let tickInterval = 60.0 / (tempo * Double(midiSequence.ticksPerQuarterNote))
        
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        timer.schedule(deadline: .now(), repeating: tickInterval, leeway: .milliseconds(1))
        timer.setEventHandler { [unowned self] in
            DispatchQueue.main.async {
                self.processEvents()
            }
        }
        timer.resume()
        
        self.timer = timer
    }

    @objc private func processEvents() {
        while midiSequence.sequence[eventIndex].ticks <= currentTimeInTicks {
            let event = midiSequence.sequence[eventIndex].event
            
            switch event {
            case let .midi(midiEvent):
                playEventSubject.send(midiEvent)
            case .beat:
                beatPublisher.send()
            case .end:
                stop()
                return
            }
            
            eventIndex += 1
        }
        
        currentTimeInTicks += 1
    }
}
