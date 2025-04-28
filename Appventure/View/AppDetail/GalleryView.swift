//
//  ScreenshotView.swift
//  Appventure
//
//  Created by 조우현 on 4/26/25.
//

import SwiftUI

struct GalleryView: View {
    let urls: [String]
    let appId: String
    @State private var currentIndex: Int
    @Environment(\.dismiss) private var dismiss
    
    init(urls: [String], initialIndex: Int, appId: String) {
        self.urls = urls
        _currentIndex = State(initialValue: initialIndex)
        self.appId = appId
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
                
                ActionButton(appId: appId)
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
