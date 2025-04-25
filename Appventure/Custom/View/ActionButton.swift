//
//  ActionButton.swift
//  Appventure
//
//  Created by 조우현 on 4/25/25.
//

import SwiftUI

struct ActionButton: View {
    var body: some View {
        Button {
            // TODO: 타이머시작/일시정지
        } label: {
            // TODO: 상태에따른 다른 레이블
            Text("받기")
                .font(.system(size: 14, weight: .semibold))
                .padding(.vertical, 6)
                .padding(.horizontal, 22)
                .background(Color(.systemGray5))
                .clipShape(Capsule())
        }
    }
}
