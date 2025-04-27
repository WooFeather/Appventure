//
//  DownloadState.swift
//  Appventure
//
//  Created by 조우현 on 4/27/25.
//

import Foundation

enum DownloadState: String {
    case notDownloaded // 받은 적 없음 (“받기”)
    case downloading // 다운로드 진행 중
    case paused // 다운로드 일시정지 (“재개”)
    case completed // 다운로드 완료 (“열기”)
    case deleted // 삭제됨 (“다시 받기”)
}
