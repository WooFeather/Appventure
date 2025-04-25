//
//  AppSearch.swift
//  Appventure
//
//  Created by 조우현 on 4/25/25.
//

import SwiftUI

// TODO: 당겨서 새로고침
// TODO: 페이지네이션
struct AppSearchView: View {
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
            .navigationDestination(for: String.self) {
                AppDetailView(viewModel: AppDetailViewModel(repository: ItunesRepository.shared), appId: $0)
            }
            .navigationTitle("검색")
        }
    }
}

// MARK: - SearchResult
private extension AppSearchView {
    func searchResultView() -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(viewModel.output.results, id: \.id) { app in
                    NavigationLink(value: app.id) {
                        AppSearchCell(app: app)
                    }
                }
            }
            .padding(.top)
        }
    }
}

// MARK: - Cell
struct AppSearchCell: View {
    let app: InfoResultEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            basicInfo(app)
            detailInfo(app)
            screenshots(app)
        }
        .padding()
    }
    
    // MARK: - Cell Function
    private func basicInfo(_ app: InfoResultEntity) -> some View {
        HStack(alignment: .center, spacing: 12) {
            AsyncCachedImage(url: URL(string: app.iconUrlSmall)) { image in
                image
                    .resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 60, height: 60)
            .cornerRadius(12)

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

            ActionButton(appId: app.id)
        }
    }
    
    private func detailInfo(_ app: InfoResultEntity) -> some View {
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
    }
    
    @ViewBuilder
    private func screenshots(_ app: InfoResultEntity) -> some View {
        if !app.screenShotsUrls.isEmpty {
            GeometryReader { geometry in
                let spacing: CGFloat = 12
                let imageCount = min(3, app.screenShotsUrls.count)
                let totalSpacing = spacing * CGFloat(imageCount - 1)
                let imageWidth = (geometry.size.width - totalSpacing) / CGFloat(imageCount)

                HStack(spacing: spacing) {
                    ForEach(app.screenShotsUrls.prefix(3), id: \.self) { url in
                        AsyncCachedImage(url: URL(string: url)) { image in
                            image
                                .resizable()
                                .clipped()
                        } placeholder: {
                            ProgressView()
                        }
                        .aspectRatio(9/16, contentMode: .fit)
                        .frame(width: imageWidth)
                        .cornerRadius(12)
                    }
                }
            }
            .frame(height: 200)
        }
    }
}

#Preview {
    AppSearchView(viewModel: AppSearchViewModel(repository: ItunesRepository.shared))
}
