//
//  AppSearch.swift
//  Appventure
//
//  Created by 조우현 on 4/25/25.
//

import SwiftUI

struct AppSearchView: View {
    @StateObject var viewModel: AppSearchViewModel
    @State private var isSearching: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                bodyContents
            }
            .searchable(
                text: $viewModel.input.term,
                isPresented: $isSearching,
                prompt: "게임, 앱, 스토리 등"
            )
            .onSubmit(of: .search) {
                viewModel.action(.search)
            }
            .onChange(of: isSearching) { oldValue, newValue in
                if !newValue {
                    viewModel.action(.clearResults)
                }
            }
            .navigationDestination(for: String.self) {
                AppDetailView(viewModel: AppDetailViewModel(repository: ItunesRepository.shared), appId: $0)
            }
            .navigationTitle("검색")
        }
    }
}

private extension AppSearchView {
    @ViewBuilder
    var bodyContents: some View {
        switch viewModel.viewState {
        case .initial:
            Text("앱을 검색해보세요")
                .asInfoText()
        case .searching:
            ProgressView()
        case .found:
            searchResultView()
        case .notFound:
            Text("검색 결과가 없습니다")
                .asInfoText()
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
                        appSearchCell(app: app)
                    }
                }
                
                if !viewModel.output.results.isEmpty {
                    HStack {
                        Spacer()
                        if viewModel.output.isLoadingMore {
                            ProgressView()
                                .padding()
                        } else if viewModel.output.hasMoreResults {
                            Button("더 보기") {
                                viewModel.action(.loadMore)
                            }
                            .padding()
                        }
                        Spacer()
                    }
                    .onAppear {
                        if !viewModel.output.isLoadingMore && viewModel.output.hasMoreResults {
                            viewModel.action(.loadMore)
                        }
                    }
                }
            }
            .padding(.top)
        }
        .refreshable { // TODO: 스크롤뷰 내부에서 작동하도록..?
          let term = viewModel.input.term.trimmingCharacters(in: .whitespaces)
          guard !term.isEmpty else { return }
          viewModel.action(.search)
        }
    }
}

// MARK: - AppSearchCell
extension AppSearchView {
    func appSearchCell(app: InfoResultEntity) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            basicInfo(app)
            detailInfo(app)
            screenshots(app)
        }
        .padding()
    }
    
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
        if !viewModel.output.downloadedIDs.contains(app.id),
           !app.screenShotsUrls.isEmpty {
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
    AppSearchView(
        viewModel: AppSearchViewModel(
            networkRepo: ItunesRepository.shared,
            realmRepo: RealmRepository.shared
        )
    )
}
