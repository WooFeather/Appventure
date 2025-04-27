//
//  SearchViewTextModifier.swift
//  Appventure
//
//  Created by 조우현 on 4/28/25.
//

import SwiftUI

private struct SearchViewTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.callout.bold())
            .foregroundStyle(.secondary)
    }
}

extension View {
    func asSearchViewText() -> some View {
        modifier(SearchViewTextModifier())
    }
}
