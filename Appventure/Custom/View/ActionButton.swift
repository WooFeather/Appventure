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
    
    // TODO: 각 상태에 맞게 버튼 모양 변경
    var body: some View {
        Button {
            handleTap()
        } label: {
            switch state {
            case .notDownloaded:
              Text("받기")
            case .downloading:
              let rem = Int(max(0,
                (object?.expectedEndDate?.timeIntervalSince(currentDate) ?? 0)
              ))
              Text("\(rem)s")
            case .paused:
              Text("재개")
            case .completed:
              Text("열기")
            case .deleted:
              Text("다시 받기")
            }
        }
        .font(.system(size: 14, weight: .semibold))
        .padding(.vertical, 6)
        .padding(.horizontal, 22)
        .background(Color(.systemGray5))
        .clipShape(Capsule())
        .buttonStyle(.borderless)
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
}
