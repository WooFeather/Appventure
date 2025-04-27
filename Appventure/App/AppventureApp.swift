//
//  AppventureApp.swift
//  Appventure
//
//  Created by 조우현 on 4/24/25.
//

import SwiftUI

@main
struct AppventureApp: App {
    init() {
      RealmRepository.shared.bootstrapOnLaunch()
    }
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
        }
    }
}
