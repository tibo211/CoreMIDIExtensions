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
    
    @Published public private(set) var inputDevices: [MIDIDevice]
    
    public init() {
        Log.info("Create midi client")
        let notificationPublisher = PassthroughSubject<MIDINotificationMessageID, Never>()
        let eventPublisher = PassthroughSubject<MIDIEvent, Never>()

        client = .create(notificationSubject: notificationPublisher)
        
        input = .input(from: client,
                       transform: { _ in .sustain(false) },
                       output: eventPublisher)
        
        output = eventPublisher
            .eraseToAnyPublisher()
        
        inputDevices = MIDIDevice.allInputDevices
        
        notificationPublisher
            .filter { $0 == .msgSetupChanged }
            .map { _ in
                let devices = MIDIDevice.allInputDevices
                Log.info("Midi setup changed:\n\(devices.map(\.name).joined(separator: "\n"))")
                return devices
            }
            .assign(to: &$inputDevices)
    }
}
