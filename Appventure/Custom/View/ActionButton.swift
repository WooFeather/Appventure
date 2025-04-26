//
//  ActionButton.swift
//  Appventure
//
//  Created by 조우현 on 4/25/25.
//

import SwiftUI
import RealmSwift

struct ActionButton: View {
    @ObservedResults(DownloadedObject.self) private var downloaded
    private var repository = RealmRepository.shared
    let appId: String
    
    private var isDownloaded: Bool {
        downloaded.contains(where: { $0.id == appId })
    }
    
    init(appId: String) {
        self.appId = appId
    }
    
    var body: some View {
        Button {
            // TODO: 타이머시작/일시정지
            download()
        } label: {
            // TODO: 상태에따른 다른 레이블
            Text(isDownloaded ? "열기" : "받기")
                .font(.system(size: 14, weight: .semibold))
                .padding(.vertical, 6)
                .padding(.horizontal, 22)
                .background(Color(.systemGray5))
                .clipShape(Capsule())
        }
        .buttonStyle(.borderless)
    }
    
    // MARK: - Action
    private func download() {
        repository.getFileURL()
        if !isDownloaded {
            let obj = DownloadedObject(value: ["id": appId])
            repository.save(obj)
        }
    }
}
