//
//  AudioSampler.swift
//  
//
//  Created by Felföldy Tibor on 2022. 12. 03.
//

import AVFoundation
import Combine

public final class AudioSampler {
    public let node: AVAudioUnitSampler
    
    private var connectedServices = [String: AnyCancellable]()
    
    private var notesPlaying = Set<Note>()
    private var pressedKeys = Set<Note>()
    
    private var sustained = false
    
    public init(soundbank: URL) throws {
        Log.info("Load soundbank...")
        node = AVAudioUnitSampler()
        
        try node.loadSoundBankInstrument(at: soundbank,
                                         program: 0,
                                         bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                                         bankLSB: UInt8(kAUSampler_DefaultBankLSB))
        Log.info("Soundbank loaded")
    }
    
    public func attach(_ service: any MIDIService) {
        connectedServices[service.name] = service.output
            .sink { [unowned self] event in
                play(event: event)
            }
    }
    
    public func deatach(_ service: any MIDIService) {
        connectedServices[service.name] = nil
    }
    
    func play(event: MIDIEvent) {
        Log.info("Sampler received: \(event)")

        switch event {
        case let .noteOn(note, velocity):
            pressedKeys.insert(note)
            notesPlaying.insert(note)
            node.startNote(note, withVelocity: velocity.midi_v1, onChannel: 0)
        case let .noteOff(note):
            pressedKeys.remove(note)
            // Stop the note only if the pedal is released.
            if !sustained {
                notesPlaying.remove(note)
                node.stopNote(note, onChannel: 0)
            }
        case let .sustain(isPressed):
            sustained = isPressed
        }
    }
}
