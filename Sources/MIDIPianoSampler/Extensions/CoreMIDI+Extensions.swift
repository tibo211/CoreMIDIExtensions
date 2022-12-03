//
//  CoreMIDI+Extensions.swift
//  
//
//  Created by Felföldy Tibor on 2022. 12. 02..
//

import Foundation
import CoreMIDI
import Combine

// MARK: - Client

extension MIDIClientRef {
    static func create(notificationSubject: PassthroughSubject<MIDINotificationMessageID, Never>) -> MIDIClientRef {
        var client = MIDIClientRef()

        // This has to be called on the main thread
        // otherwise the client notification won't be received.
        MIDIClientCreateWithBlock("MIDIEngineClient" as CFString, &client) { message in
            notificationSubject.send(message.pointee.messageID)
        }
        return client
    }
}

// MARK: - Ports

extension MIDIPortRef {
    static func input(from client: MIDIClientRef,
                      coder: MIDICodingStrategy,
                      output eventSubject: PassthroughSubject<MIDIEvent, Never>) -> MIDIPortRef {
        var inputPort = MIDIPortRef()
        MIDIInputPortCreateWithProtocol(client, "MIDIEngineInputPort" as CFString,
                                        coder.verion,
                                        &inputPort) { eventList, pointer in
            let packetCount = Int(eventList.pointee.numPackets)

            Log.info("\(packetCount) UME received.")
            
            UnsafeBufferPointer(start: eventList, count: packetCount)
                .map(\.packet)
                .compactMap(coder.decode)
                .forEach { event in
                    eventSubject.send(event)
                }
        }
        return inputPort
    }
}

// MARK: - Objects

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

