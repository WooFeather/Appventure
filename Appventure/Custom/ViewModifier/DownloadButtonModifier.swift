//
//  DownloadButtonModifier.swift
//  Appventure
//
//  Created by 조우현 on 4/27/25.
//

import SwiftUI

private struct DownloadButtonModifier: ViewModifier{
    func body(content: Content) -> some View {
        content
            .font(.system(size: 14, weight: .semibold))
            .padding(.vertical, 6)
            .padding(.horizontal, 20)
            .background(Color(.systemGray5))
            .clipShape(Capsule())
    }
}

extension View {
    func asDownloadButton() -> some View {
        modifier(DownloadButtonModifier())
    }
}
