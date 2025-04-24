//
//  Tab.swift
//  Appventure
//
//  Created by 조우현 on 4/24/25.
//

import Foundation

enum Tab: Identifiable, CaseIterable {
    case today
    case game
    case app
    case arcade
    case search
    
    var id: UUID {
        return .init()
    }
    
    var icon: String {
        switch self {
        case .today:
            return "doc.text.image"
        case .game:
            return "gamecontroller"
        case .app:
            return "square.stack.3d.up"
        case .arcade:
            return "arcade.stick.console"
        case .search:
            return "magnifyingglass"
        }
    }
    
    var title: String {
        switch self {
        case .today:
            return "투데이"
        case .game:
            return "게임"
        case .app:
            return "앱"
        case .arcade:
            return "Arcade"
        case .search:
            return "검색"
        }
    }
}
