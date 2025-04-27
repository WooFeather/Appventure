//
//  SearchViewTextModifier.swift
//  Appventure
//
//  Created by 조우현 on 4/28/25.
//

import SwiftUI

private struct InfoTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.callout.bold())
            .foregroundStyle(.secondary)
    }
}

extension View {
    func asInfoText() -> some View {
        modifier(InfoTextModifier())
    }
}
