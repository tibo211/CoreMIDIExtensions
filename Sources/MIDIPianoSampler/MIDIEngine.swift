//
//  MIDIEngine.swift
//  
//
//  Created by Felföldy Tibor on 2022. 12. 02.
//

import Foundation
import CoreMIDI
import Combine

public final class MIDIEngine: MIDIService, ObservableObject {
    private let client: MIDIClientRef
    private let input: MIDIPortRef

    public let output: AnyPublisher<MIDIEvent, Never>
    
    @Published private(set) var inputDevices = [MIDIDevice]()
    
    init() {
        Log.info("Create midi client")
        let notificationPublisher = PassthroughSubject<MIDINotificationMessageID, Never>()
        let eventPublisher = PassthroughSubject<MIDIEvent, Never>()

        client = .create(notificationSubject: notificationPublisher)
        
        input = .input(from: client,
                       transform: { _ in .sustain(false) },
                       output: eventPublisher)
        
        output = eventPublisher
            .eraseToAnyPublisher()
        
        notificationPublisher
            .filter { $0 == .msgSetupChanged }
            .map { _ in
                MIDIDevice.allInputDevices
            }
            .assign(to: &$inputDevices)
    }
}
