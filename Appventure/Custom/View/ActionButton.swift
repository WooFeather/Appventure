//
//  ActionButton.swift
//  Appventure
//
//  Created by 조우현 on 4/25/25.
//

import SwiftUI
import RealmSwift

// TODO: MVVM으로 분리
struct ActionButton: View {
    @ObservedResults(DownloadedObject.self) private var downloaded
    let appId: String
    
    private let realmRepo = RealmRepository.shared
    
    // 뷰 갱신 트리거
    @State private var currentDate: Date = Date()
    
    // 1초마다 체크
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var object: DownloadedObject? {
        downloaded.first { $0.id == appId }
    }
    
    private var state: DownloadState {
        object?.state ?? .notDownloaded
    }
    
    var body: some View {
        Button {
            handleTap()
        } label: {
            switch state {
            case .notDownloaded:
                basicButton("받기")
            case .downloading:
                downloadingButton()
            case .paused:
                basicButton("재개", isPaused: true)
            case .completed:
                basicButton("열기")
            case .deleted:
                reDownloadButton()
            }
        }
        .buttonStyle(.borderless)
//        .animation(.spring, value: state)
        .onReceive(timer) {
          // @State에게 타이머가 진행될때마다 해당 값을 전달해줌 => 렌더링
          currentDate = $0
        }
    }
    
    private func handleTap() {
        switch state {
        case .notDownloaded, .deleted:
            realmRepo.startDownload(appId: appId)
        case .downloading:
            realmRepo.pauseDownload(appId: appId)
        case .paused:
            realmRepo.resumeDownload(appId: appId)
        case .completed:
            openApp()
        }
    }
    
    private func openApp() {
        print("앱 열기")
    }
    
    // MARK: - ButtonView
    @ViewBuilder
    private func basicButton(_ title: String, isPaused: Bool = false) -> some View {
        if !isPaused {
            Text(title)
                .asDownloadButton()
        } else {
            HStack(spacing: 2) {
                Image(systemName: "icloud.and.arrow.down")
                Text(title)
            }
            .asDownloadButton()
        }
    }
    
    private func reDownloadButton() -> some View {
        Image(systemName: "icloud.and.arrow.down")
    }
    
    private func downloadingButton() -> some View {
        let total: TimeInterval = 30
        let timeLeft = max(0, (object?.expectedEndDate?.timeIntervalSince(currentDate) ?? total))
        let progress = min(max(1 - timeLeft / total, 0), 1)

        return ZStack {
            Circle()
                .stroke(Color(.systemGray4), lineWidth: 2)

            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .foregroundColor(.blue)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)

            Image(systemName: "pause.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.blue)
        }
        .frame(width: 30, height: 30)
    }
}
