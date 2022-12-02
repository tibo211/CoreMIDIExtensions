//
//  CoreMIDI+Extensions.swift
//  
//
//  Created by Felföldy Tibor on 2022. 12. 02..
//

import CoreMIDI

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
