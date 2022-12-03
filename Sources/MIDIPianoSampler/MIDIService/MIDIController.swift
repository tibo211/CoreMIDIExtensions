//
//  MIDIController.swift
//  
//
//  Created by Felföldy Tibor on 2022. 12. 02.
//

import Foundation
import CoreMIDI
import Combine

public final class MIDIController: MIDIService, ObservableObject {
    public let name = "MIDI Controller"
    private let client: MIDIClientRef
    private let inputPort: MIDIPortRef

    public let output: AnyPublisher<MIDIEvent, Never>
    
    @Published public private(set) var inputDevices: [MIDIDevice]
    @Published public private(set) var selectedInputs = Set<MIDIDevice>()
    
    public init(decoder: MIDICodingStrategy? = nil) {
        let decoder = decoder ?? MIDICoding_v1()
        
        Log.info("Create midi client")
        let notificationPublisher = PassthroughSubject<MIDINotificationMessageID, Never>()
        let eventPublisher = PassthroughSubject<MIDIEvent, Never>()

        client = .create(notificationSubject: notificationPublisher)
        
        inputPort = .input(from: client,
                           coder: decoder,
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
    
    public func set(device: MIDIDevice) {
        if !selectedInputs.contains(device) {
            // Connect device.
            device.connect(port: inputPort)
            selectedInputs.insert(device)
            Log.info("\(device.name) connected.")
        } else {
            // Disconnect device.
            device.disconnect(port: inputPort)
            selectedInputs.remove(device)
            Log.info("\(device.name) disconnected.")
        }
    }
}
