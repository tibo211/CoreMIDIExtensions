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
    private let input: MIDIPortRef
    
    init() {
        Log.info("Create midi client")
        
        client = .create { notification in
            
        }
        
        input = .input(from: client, transform: { _ in .sustain(false) }) { events in
            
        }
    }
}
