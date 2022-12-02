//
//  MIDIService.swift
//  
//
//  Created by Felföldy Tibor on 2022. 12. 02.
//

import Combine

public protocol MIDIService {
    var output: AnyPublisher<MIDIEvent, Never> { get }
}
