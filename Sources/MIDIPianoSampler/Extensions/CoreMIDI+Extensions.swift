//
//  CoreMIDI+Extensions.swift
//  
//
//  Created by Felföldy Tibor on 2022. 12. 02..
//

import Foundation
import CoreMIDI

extension MIDIClientRef {
    static func create(nofifyChanges: @escaping (MIDINotificationMessageID) -> Void) -> MIDIClientRef {
        var client = MIDIClientRef()

        // For some reason this has to be called on the main thread
        // otherwise the client notification won't be received.
        MIDIClientCreateWithBlock("MIDIEngineClient" as CFString, &client) { message in
            nofifyChanges(message.pointee.messageID)
        }
        return client
    }
}

extension MIDIPortRef {
    static func input(from client: MIDIClientRef,
                      transform: @escaping (MIDIEventPacket) -> MIDIEvent,
                      eventsHandler: @escaping ([MIDIEvent]) -> Void) -> MIDIPortRef {
        var inputPort = MIDIPortRef()
        MIDIInputPortCreateWithProtocol(client, "MIDIEngineInputPort" as CFString, ._1_0, &inputPort) { eventList, pointer in
            
            let packetCount = Int(eventList.pointee.numPackets)
            
            let events = UnsafeBufferPointer(start: eventList, count: packetCount)
                .map(\.packet)
                .map(transform)
            
            eventsHandler(events)
        }
        return inputPort
    }
}

extension MIDIObjectRef {
    var properties: [String : Any] {
        var unmanagedProperties: Unmanaged<CFPropertyList>?
        _ = MIDIObjectGetProperties(self, &unmanagedProperties, true)
        let properties = unmanagedProperties?.takeUnretainedValue()
        return properties as? [String: Any] ?? [:]
    }
    
    var id: Int {
        // Probably every MIDIObject has to have a uniqueID.
        properties["uniqueID"] as! Int
    }
    
    var name: String? {
        properties["name"] as? String
    }
}

