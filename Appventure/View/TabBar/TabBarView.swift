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
            
            MyAppView()
                .asTabModifier(.app)
            
            ArcadeView()
                .asTabModifier(.arcade)
            
            AppSearch(viewModel: AppSearchViewModel(repository: ItunesRepository.shared))
                .asTabModifier(.search)
        }
    }
}

#Preview {
    TabBarView()
}
