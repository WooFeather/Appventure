//
//  SectionTitleModifier.swift
//  Appventure
//
//  Created by 조우현 on 4/25/25.
//

import SwiftUI

private struct SectionTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title3.bold())
            .padding(.horizontal)
    }
}

extension View {
    func asSectionTitle() -> some View {
        modifier(SectionTitleModifier())
    }
}
