//
//  String+.swift
//  Appventure
//
//  Created by 조우현 on 4/25/25.
//

import Foundation

extension String {
    var relativeDate: String {
        let isoFormatter = ISO8601DateFormatter()
        guard let date = isoFormatter.date(from: self) else { return "" }
        let relFormatter = RelativeDateTimeFormatter()
        relFormatter.unitsStyle = .abbreviated
        return relFormatter.localizedString(for: date, relativeTo: .now)
    }
}
