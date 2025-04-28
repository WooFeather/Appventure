//
//  AppDetailView.swift
//  Appventure
//
//  Created by 조우현 on 4/25/25.
//

import SwiftUI

struct ScreenshotItem: Identifiable {
    let id: Int
}

struct AppDetailView: View {
    @StateObject var viewModel: AppDetailViewModel
    let appId: String
    
    @State private var presentedItem: ScreenshotItem? = nil
    
    var body: some View {
        Group {
            if viewModel.output.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let app = viewModel.output.app {
                ScrollView {
                    VStack(alignment: .leading) {
                        header(app)
                        metaInfoScroll(app)
                        newFeatures(app)
                        previewScreenshots(app)
                        additionalInfo(app)
                    }
                }
            } else {
                Text("앱 정보를 불러오지 못했습니다.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            viewModel.action(.fetchApp(appId))
        }
    }
}

// MARK: - Header
private extension AppDetailView {
    func header(_ app: InfoResultEntity) -> some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncCachedImage(url: URL(string: app.iconUrlLarge)) { image in
                image
                    .resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            
            VStack(alignment: .leading) {
                Text(app.name)
                    .font(.title3.bold())
                    .lineLimit(2)
                
                Spacer()
                
                ActionButton(appId: app.id)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - MetaInfo
private extension AppDetailView {
    func metaCard(_ label: String, _ value: String) -> some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.caption2)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
        }
        .foregroundStyle(.secondary)
        .frame(width: 80)
    }
    
    func metaInfoScroll(_ app: InfoResultEntity) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Divider()
                .padding()
            
            HStack {
                metaCard("버전", "\(app.minimumVersion)+")
                divider
                metaCard("연령", app.age)
                divider
                metaCard("카테고리", app.genres.first ?? app.primaryGenreName)
                divider
                metaCard("개발자", app.corpName)
                divider
                metaCard("언어", app.languages[0])
            }
            .padding(.horizontal)
            
            Divider()
                .padding()
        }
    }
    
    var divider: some View {
        Divider()
            .frame(height: 36)
    }
}

// MARK: - NewFeature
private extension AppDetailView {
    func newFeatures(_ app: InfoResultEntity) -> some View {
        
        return VStack(alignment: .leading, spacing: 8) {
            Text("새로운 소식")
                .asSectionTitle()
            
            HStack {
                Text("버전 \(app.version)")
                Spacer()
                Text(app.currentReleaseDate.relativeDate)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.horizontal)
            
            ExpandableText(app.releaseNotes, lineLimit: 3)
                .font(.callout)
                .padding(.horizontal)
        }
    }
}

// MARK: - Screenshot
private extension AppDetailView {
    func previewScreenshots(_ app: InfoResultEntity) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("미리 보기")
                .asSectionTitle()
            
            if app.screenShotsUrls.isEmpty {
                Text("스크린샷이 제공되지 않습니다.")
                    .foregroundStyle(.gray)
                    .font(.callout.bold())
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(Array(app.screenShotsUrls.enumerated()), id: \.0) { index, url in
                            AsyncCachedImage(url: URL(string: url)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(0.55, contentMode: .fit)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 230)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .onTapGesture {
                                presentedItem = ScreenshotItem(id: index)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
        .fullScreenCover(item: $presentedItem) { item in
            GalleryView(
                urls: app.screenShotsUrls,
                initialIndex: item.id,
                appId: app.id
            )
        }
    }
}

// MARK: - AdditionalInfo
private extension AppDetailView {
    func additionalInfo(_ app: InfoResultEntity) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("정보")
                .asSectionTitle()
            
            infoRow("카테고리", app.genres.first ?? app.primaryGenreName)
            Divider()
                .padding(.horizontal)
            infoRow("가격", app.price)
            Divider()
                .padding(.horizontal)
            infoRow("최소 버전", "iOS \(app.minimumVersion)+")
            Divider()
                .padding(.horizontal)
            infoRow("지원 언어", app.languages.languageWithCount)
        }
        .padding(.bottom)
    }
    
    func infoRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
                .font(.footnote)
            
            Spacer()
            
            Text(value)
                .font(.footnote)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
}


#Preview {
    AppDetailView(viewModel: AppDetailViewModel(repository: ItunesRepository.shared), appId: "1464496236")
}
