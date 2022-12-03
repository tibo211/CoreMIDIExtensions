//
//  MIDIDevice.swift
//  
//
//  Created by Felföldy Tibor on 2022. 12. 02..
//

import CoreMIDI

public struct MIDIEndpoint: Identifiable {
    public let id: Int
    fileprivate let ref: MIDIEndpointRef
    
    init(_ endpoint: MIDIEndpointRef) {
        id = endpoint.id
        ref = endpoint
    }
}

public struct MIDIDevice: Identifiable {
    public let id: Int
    public let name: String
    public let inputs: [MIDIEndpoint]
    
    init(_ device: MIDIDeviceRef) {
        id = device.id
        name = device.name ?? "unknown"
        
        inputs = {
            // Extract source IDs from device properties.
            let deviceSources = (device.properties["entities"] as? [[String: Any]] ?? [])
                .compactMap { $0["sources"] as? [[String: Any]] }
                .flatMap { $0 }
                .compactMap { $0["uniqueID"] as? Int }
            
            // Find sources associated with the device.
            return (0 ..< MIDIGetNumberOfSources())
                .map(MIDIGetSource)
                .filter { deviceSources.contains($0.id) }
                .map(MIDIEndpoint.init)
        }()
    }
    
    func connect(port: MIDIPortRef) {
        inputs.map(\.ref).forEach { ref in
            MIDIPortConnectSource(port, ref, nil)
        }
    }
    
    func disconnect(port: MIDIPortRef) {
        inputs.map(\.ref).forEach { ref in
            MIDIPortDisconnectSource(port, ref)
        }
    }
}

extension MIDIDevice {
    /// All devices containing input endpoints.
    static var allInputDevices: [MIDIDevice] {
        (0 ..< MIDIGetNumberOfDevices())
            .map(MIDIGetDevice)
            .map(MIDIDevice.init)
            .filter { !$0.inputs.isEmpty }
    }
}

extension MIDIDevice: Hashable {
    public static func == (lhs: MIDIDevice, rhs: MIDIDevice) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
