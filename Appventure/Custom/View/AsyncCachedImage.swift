//
//  AsyncCachedImage.swift
//  Appventure
//
//  Created by 조우현 on 4/26/25.
//

import SwiftUI

struct AsyncCachedImage<ImageView: View, PlaceholderView: View>: View {
    var url: URL?
    @ViewBuilder var content: (Image) -> ImageView
    @ViewBuilder var placeholder: () -> PlaceholderView
    
    @State var image: UIImage? = nil
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> ImageView,
        @ViewBuilder placeholder: @escaping () -> PlaceholderView
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        VStack {
            if let uiImage = image {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
                    .onAppear {
                        Task {
                            image = await downloadPhoto()
                        }
                    }
            }
        }
    }
    
    private func downloadPhoto() async -> UIImage? {
        do {
            guard let url else { return nil }
            
            if let cachedResponse = URLCache.shared.cachedResponse(for: .init(url: url)) {
                return UIImage(data: cachedResponse.data)
            } else {
                let (data, response) = try await URLSession.shared.data(from: url)
                
                URLCache.shared.storeCachedResponse(.init(response: response, data: data), for: .init(url: url))
                
                guard let image = UIImage(data: data) else {
                    return nil
                }
                
                return image
            }
        } catch {
            print("Error downloading: \(error)")
            return nil
        }
    }
}
