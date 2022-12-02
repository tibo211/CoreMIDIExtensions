//
//  MIDIEngine.swift
//  
//
//  Created by Felföldy Tibor on 2022. 12. 02.
//

import Foundation
import CoreMIDI

public final class MIDIEngine {
    private let client: MIDIClientRef
    
    init() {
        Log.info("Create midi client")
        var client = MIDIClientRef()

        // For some reason this has to be called on the main thread
        // otherwise the client notification won't be called.
        MIDIClientCreateWithBlock("MIDIEngineClient" as CFString, &client) { message in
            // TODO: Refresh input ports.
        }
        
        self.client = client
    }
}
