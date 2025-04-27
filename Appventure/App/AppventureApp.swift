//
//  AppventureApp.swift
//  Appventure
//
//  Created by 조우현 on 4/24/25.
//

import SwiftUI

@main
struct AppventureApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            TabBarView(realmRepo: RealmRepository.shared)
        }
    }
}
