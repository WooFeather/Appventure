//
//  TabBarView.swift
//  Appventure
//
//  Created by 조우현 on 4/24/25.
//

import SwiftUI

struct TabBarView: View {
    
    @State private var selectedTab: Tab = .today
    
    var body: some View {
        TabView {
            TodayView()
                .asTabModifier(.today)
            
            GameView()
                .asTabModifier(.game)
            
            MyAppView(
                viewModel: MyAppViewModel(
                    networkRepo: ItunesRepository.shared,
                    realmRepo: RealmRepository.shared
                )
            )
                .asTabModifier(.app)
            
            ArcadeView()
                .asTabModifier(.arcade)
            
            AppSearchView(
                viewModel: AppSearchViewModel(
                    networkRepo: ItunesRepository.shared,
                    realmRepo: RealmRepository.shared
                )
            )
                .asTabModifier(.search)
        }
    }
}

#Preview {
    TabBarView()
}
