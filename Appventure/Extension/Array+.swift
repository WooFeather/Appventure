//
//  Array+.swift
//  Appventure
//
//  Created by 조우현 on 4/25/25.
//

import Foundation

extension Array where Element == String {
    var languageWithCount: String {
        guard let first = first else { return "-" }
        if count <= 2 { return joined(separator: ", ") }
        return "\(first) 외 \(count - 1)개"
    }
}
