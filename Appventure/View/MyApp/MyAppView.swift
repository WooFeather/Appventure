//
//  MyAppView.swift
//  Appventure
//
//  Created by 조우현 on 4/25/25.
//

import SwiftUI

struct MyAppView: View {
    @StateObject var viewModel: MyAppViewModel
    
    // TODO: 실시간 검색기능
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.output.isLoading {
                    ProgressView()
                } else {
                    downloadedView()
                }
            }
            .navigationTitle("앱")
        }
        .onAppear {
            viewModel.action(.fetchDownloaded)
        }
    }
}

// MARK: - DownloadedView
private extension MyAppView {
    func downloadedView() -> some View {
        ScrollView {
            let items = viewModel.output.downloadedApps
            
            LazyVStack(spacing: 0) {
                ForEach(items.indices, id: \.self) { idx in
                    DownloadedAppCell(item: items[idx])
                    
                    if idx < items.count - 1 {
                        Divider()
                            .padding(.leading, 84)
                    }
                }
            }
        }
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
        .padding(.horizontal)
        .padding(.vertical, 12)
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
