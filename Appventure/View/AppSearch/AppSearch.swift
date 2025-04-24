//
//  AppSearch.swift
//  Appventure
//
//  Created by 조우현 on 4/25/25.
//

import SwiftUI

struct AppSearch: View {
    @StateObject var viewModel: AppSearchViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.output.isLoading {
                    ProgressView()
                } else {
                    searchResultView()
                }
            }
            .searchable(text: $viewModel.input.term, prompt: "게임, 앱, 스토리 등")
            .onSubmit(of: .search) {
                viewModel.action(.search)
            }
            .navigationTitle("검색")
        }
    }
    
    private func searchResultView() -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(viewModel.output.results, id: \.id) { app in
                    AppSearchCell(app: app)
                        .padding(.horizontal)
                }
            }
            .padding(.top)
        }
    }
}

struct AppSearchCell: View {
    let app: InfoResultEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                AsyncImage(url: URL(string: app.iconUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .frame(width: 60, height: 60)
                            .cornerRadius(12)
                    case .failure(_):
                        Color.gray
                            .frame(width: 60, height: 60)
                            .cornerRadius(12)
                    default:
                        ProgressView()
                            .frame(width: 60, height: 60)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(app.name)
                        .lineLimit(1)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(app.genres.joined(separator: ", "))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: {}) {
                    Text("받기")
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 22)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                }
            }

            HStack(spacing: 6) {
                Text("iOS \(app.minimumVersion)")
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "person.crop.square")
                    Text(app.corpName)
                        .lineLimit(1)
                }
                Spacer()
                Text(app.primaryGenreName)
            }
            .font(.system(size: 11).bold())
            .foregroundColor(.gray)

            if !app.screenShotsUrls.isEmpty {
                GeometryReader { geometry in
                    let spacing: CGFloat = 12
                    let imageCount = min(3, app.screenShotsUrls.count)
                    let totalSpacing = spacing * CGFloat(imageCount - 1)
                    let imageWidth = (geometry.size.width - totalSpacing) / CGFloat(imageCount)

                    HStack(spacing: spacing) {
                        ForEach(app.screenShotsUrls.prefix(3), id: \.self) { url in
                            AsyncImage(url: URL(string: url)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(9/16, contentMode: .fit)
                                        .frame(width: imageWidth)
                                        .cornerRadius(12)
                                        .clipped()
                                case .failure(_):
                                    Color.gray
                                        .frame(width: imageWidth)
                                        .aspectRatio(9/16, contentMode: .fit)
                                        .cornerRadius(12)
                                default:
                                    ProgressView()
                                        .frame(width: imageWidth)
                                        .aspectRatio(9/16, contentMode: .fit)
                                }
                            }
                        }
                    }
                }
                .frame(height: 200)
            }

        }
        .padding(.vertical, 12)
    }
}

#Preview {
    AppSearch(viewModel: AppSearchViewModel(repository: ItunesRepository.shared))
}
