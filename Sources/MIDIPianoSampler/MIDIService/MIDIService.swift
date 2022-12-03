//
//  MIDIService.swift
//  
//
//  Created by Felföldy Tibor on 2022. 12. 02.
//

import Foundation
import Combine

public protocol MIDIService {
    var name: String { get }
    var output: AnyPublisher<MIDIEvent, Never> { get }
}
