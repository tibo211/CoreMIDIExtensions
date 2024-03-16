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
    public let beatPublisher = PassthroughSubject<Void, Never>()
    
    public var isPlaying: Bool {
        startTime != nil
    }

    public var tempo: Double = 60 {
        didSet { setTimer() }
    }

    private var midiSequence: MIDISequence
    private var eventIndex = 0
    private var currentTimeInTicks: UInt32 = 0
    private var timer: DispatchSourceTimer?
    private var startTime: Date?
    private let playEventSubject = PassthroughSubject<MIDIEvent, Never>()
    private let queue = DispatchQueue(label: "com.MIDISequencePlayer.queue", qos: .userInteractive)

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
        let ticksPerSecond = (tempo / 60) * Double(midiSequence.ticksPerQuarterNote)
        let elapsedTimeInSeconds = Double(currentTimeInTicks) / ticksPerSecond
        startTime = Date().addingTimeInterval(-elapsedTimeInSeconds)
        
        setTimer()
    }

    public func stop() {
        startTime = nil
        timer?.cancel()
        timer = nil
        eventIndex = 0
        currentTimeInTicks = 0
    }
    
    private func setTimer() {
        timer?.cancel()
        
        guard startTime != nil else { return }
        
        let tickInterval = 60.0 / (tempo * Double(midiSequence.ticksPerQuarterNote))
        
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        timer.schedule(deadline: .now(), repeating: tickInterval)
        timer.setEventHandler { [unowned self] in
            processEvents()
        }
        timer.resume()
        
        self.timer = timer
    }

    @objc private func processEvents() {
        guard let startTime else { return }

        // Update currentTimeInTicks based on physical time.
        let elapsedTime = Date().timeIntervalSince(startTime)
        let ticksPerSecond = (tempo / 60) * Double(midiSequence.ticksPerQuarterNote)
        currentTimeInTicks = UInt32(elapsedTime * ticksPerSecond)
        
        while eventIndex < midiSequence.sequence.count &&
              midiSequence.sequence[eventIndex].ticks <= currentTimeInTicks {
            let event = midiSequence.sequence[eventIndex].event
            
            DispatchQueue.main.async { [self] in
                switch event {
                case let .midi(midiEvent):
                    playEventSubject.send(midiEvent)
                case .beat:
                    beatPublisher.send()
                case .end:
                    stop()
                    return
                }
            }
            
            eventIndex += 1
        }
        
        currentTimeInTicks += 1
    }
}
