//
//  ScreenshotView.swift
//  Appventure
//
//  Created by 조우현 on 4/26/25.
//

import SwiftUI

// TODO: 두 번째 스크린샷을 탭했을때 첫 번째 스크린샷이 뜨는 문제 해결
struct GalleryView: View {
    let urls: [String]
    @State private var currentIndex: Int
    @Environment(\.dismiss) private var dismiss
    
    init(urls: [String], initialIndex: Int) {
        self.urls = urls
        _currentIndex = State(initialValue: initialIndex)
    }
    
    var body: some View {
        VStack {
            HStack {
                Button("완료") {
                    dismiss()
                }
                .font(.callout.bold())
                .tint(.blue)
                
                Spacer()
                
                // TODO: 버튼상태 동기화
                ActionButton(appId: "00000")
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            TabView(selection: $currentIndex) {
                ForEach(Array(urls.enumerated()), id: \.0) { index, url in
                    AsyncCachedImage(url: URL(string: url)) { img in
                        img
                            .resizable()
                            .aspectRatio(0.55, contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 350)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}

//#Preview {
//    GalleryView()
//}
