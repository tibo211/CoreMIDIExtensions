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

// MARK: - Modifiers

public protocol MIDIServiceModifier: MIDIService {
    var modifierName: String { get }
    var base: MIDIService { get }
}

extension MIDIServiceModifier {
    var name: String {
        "\(base.name)>\(modifierName)"
    }
}

struct VelocityModifier: MIDIServiceModifier {
    let modifierName = "Velocity"
    let base: MIDIService
    let transform: (Float) -> Float
    
    init(base: MIDIService, transform: @escaping (Float) -> Float) {
        self.base = base
        self.transform = transform
    }
    
    var output: AnyPublisher<MIDIEvent, Never> {
        base.output.map { event in
            if case let .noteOn(note, x) = event {
                return .noteOn(note: note, velocity: transform(x))
            }
            return event
        }
        .eraseToAnyPublisher()
    }
}

public extension MIDIService {
    func velocityCurve(_ transform: @escaping (Float) -> Float) -> MIDIService {
        VelocityModifier(base: self, transform: transform)
    }
}
