//
//  MIDIDevice.swift
//  
//
//  Created by Felföldy Tibor on 2022. 12. 02..
//

import CoreMIDI

public struct MIDIDevice: Identifiable {
    public let id: Int
    public let name: String
    
    init(_ device: MIDIDeviceRef) {
        id = device.id
        name = device.name ?? "unknown"
    }
}
