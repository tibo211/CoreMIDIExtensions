//
//  String+Extensions.swift
//  
//
//  Created by Felföldy Tibor on 2022. 12. 03.
//

import Foundation

extension String {
    init<Number: BinaryInteger>(binary number: Number, size: Int) {
        let number = String(number, radix: 2)
        let fill = [String](repeating: "0", count: size - number.count)
        self.init((fill + [number]).joined())
    }
}
