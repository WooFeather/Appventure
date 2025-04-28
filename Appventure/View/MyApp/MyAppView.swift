//
//  MyAppView.swift
//  Appventure
//
//  Created by 조우현 on 4/25/25.
//

import SwiftUI

struct MyAppView: View {
    @StateObject var viewModel: MyAppViewModel
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.output.isLoading {
                    ProgressView()
                } else if viewModel.output.filteredDownloadedApps.isEmpty {
                    Text("다운로드 한 앱이 없습니다")
                        .asInfoText()
                } else {
                    downloadedView()
                }
            }
            .navigationTitle("앱")
            .navigationDestination(for: String.self) {
                AppDetailView(viewModel: AppDetailViewModel(repository: ItunesRepository.shared), appId: $0)
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "게임, 앱, 스토리 등")
            .onChange(of: searchText) { oldValue, newValue in
                viewModel.input.searchQuery.send(newValue)
            }
        }
        .onAppear {
            viewModel.action(.fetchDownloaded)
        }
    }
}

// MARK: - DownloadedView
private extension MyAppView {
    func downloadedView() -> some View {
        List {
            ForEach(viewModel.output.filteredDownloadedApps) { item in
                NavigationLink(value: item.id) {
                    DownloadedAppCell(item: item)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        viewModel.action(.deleteApp(item.id))
                    } label: {
                        Label("삭제", systemImage: "trash")
                    }
                }
            }
        }
        .refreshable {
            viewModel.action(.fetchDownloaded)
        }
        .listStyle(.plain)
    }
}

// MARK: - Cell
private struct DownloadedAppCell: View {
    let item: DownloadedAppItem
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            
            AsyncCachedImage(url: URL(string: item.info.iconUrlSmall)) { image in
                image
                    .resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 60, height: 60)
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.info.name)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)
                Text(item.date.toString(dateFormat: "yyyy. M. d"))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            ActionButton(appId: item.id)
        }
    }
}


#Preview {
    MyAppView(
        viewModel: MyAppViewModel(
            networkRepo: ItunesRepository.shared,
            realmRepo: RealmRepository.shared
        )
    )
}
