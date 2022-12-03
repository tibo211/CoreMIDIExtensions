//
//  AudioSampler.swift
//  
//
//  Created by Felföldy Tibor on 2022. 12. 03.
//

import AVFoundation
import Combine

public final class AudioSampler {
    static let sampler = AVAudioUnitSampler()
    
    private var connectedServices = [String: AnyCancellable]()
    
    public init() {}
    
    deinit {
        connectedServices.values.forEach { cancellable in
            cancellable.cancel()
        }
    }
    
    func play(event: MIDIEvent) {
        Log.info("Sampler received: \(event)")
    }
    
    public func attach(_ service: any MIDIService) {
        connectedServices[service.name] = service.output
            .sink { [unowned self] event in
                play(event: event)
            }
    }
}
