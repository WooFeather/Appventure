//
//  DownloadedObject.swift
//  Appventure
//
//  Created by 조우현 on 4/26/25.
//

import Foundation
import RealmSwift

final class DownloadedObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var createdAt: Date = Date()
    @Persisted var stateRaw: String = DownloadState.notDownloaded.rawValue
    @Persisted var expectedEndDate: Date? // 절대 완료 시각
    @Persisted var remainingTime: TimeInterval = 0 // 일시정지 시점 남은 초
    @Persisted var isDeleted: Bool = false // 실제 삭제가 아닌, 플래그

    var state: DownloadState {
      get { DownloadState(rawValue: stateRaw)! }
      set { stateRaw = newValue.rawValue }
    }
}
