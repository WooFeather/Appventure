//
//  AppDetailView.swift
//  Appventure
//
//  Created by 조우현 on 4/25/25.
//

import SwiftUI

struct AppDetailView: View {
    @StateObject var viewModel: AppDetailViewModel
    let appId: Int
    
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

// MARK: - SECTION 1. 헤더
private extension AppDetailView {
    func header(_ app: InfoResultEntity) -> some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncImage(url: URL(string: app.iconUrl)) { phase in
                switch phase {
                case .success(let img):
                    img
                        .resizable()
                case .empty:
                    ProgressView()
                default:
                    Image(systemName: "app").resizable()
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            
            VStack(alignment: .leading) {
                Text(app.name)
                    .font(.title3.bold())
                    .lineLimit(2)
                
                Spacer()
                
                // TODO: Custom으로 빼기
                Button("열기") { /* 앱 실행 로직 */ }
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 22)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal)
    }
}
// MARK: - SECTION 2. 메타 정보 (버전·연령·카테고리·개발자)
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

// MARK: - SECTION 3. 새로운 소식 (릴리즈 노트)
private extension AppDetailView {
    func newFeatures(_ app: InfoResultEntity) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("새로운 소식")
                .font(.headline)
                .padding(.horizontal)
            
            HStack {
                Text("버전 \(app.version)")
                Spacer()
                Text(relativeDate(app.currentReleaseDate))
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.horizontal)
            
            Text(app.releaseNotes.isEmpty ? "릴리즈 노트가 없습니다." : app.releaseNotes)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
        }
    }
    
    // TODO: Extension
    func relativeDate(_ iso: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        guard let date = isoFormatter.date(from: iso) else { return "" }
        let relFormatter = RelativeDateTimeFormatter()
        relFormatter.unitsStyle = .abbreviated
        return relFormatter.localizedString(for: date, relativeTo: .now)
    }
}

// MARK: - SECTION 4. 미리 보기 (스크린샷 캐러셀)
private extension AppDetailView {
    func previewScreenshots(_ app: InfoResultEntity) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("미리 보기")
                .font(.headline)
                .padding(.horizontal)
            
            // TODO: 탭하면 스크린샷 확대 화면 sheet
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(app.screenShotsUrls, id: \.self) { url in
                        AsyncImage(url: URL(string: url)) { phase in
                            switch phase {
                            case .success(let img):
                                img.resizable()
                                   .aspectRatio(0.55, contentMode: .fit)
                            case .empty:
                                ProgressView()
                            default:
                                Color.gray.opacity(0.2)
                            }
                        }
                        .frame(width: 230)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 4)
            }
        }
        .padding(.vertical)
    }
}
// MARK: - SECTION 5. 추가 정보 (지원 언어·가격 등)
private extension AppDetailView {
    
    func additionalInfo(_ app: InfoResultEntity) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("정보")
                .font(.headline)
                .padding(.horizontal)
            
            infoRow("카테고리", app.genres.first ?? app.primaryGenreName)
            infoRow("가격", app.price)
            infoRow("최소 버전", "iOS \(app.minimumVersion)+")
            infoRow("지원 언어", languageLine(app.languages))
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
    
    // TODO: Extension
    func languageLine(_ langs: [String]) -> String {
        guard let first = langs.first else { return "-" }
        if langs.count <= 2 { return langs.joined(separator: ", ") }
        return first + " 외 \(langs.count - 1)개"
    }
}


#Preview {
    AppDetailView(viewModel: AppDetailViewModel(repository: ItunesRepository.shared), appId: 1464496236)
}
