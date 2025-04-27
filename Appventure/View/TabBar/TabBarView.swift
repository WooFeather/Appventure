//
//  TabBarView.swift
//  Appventure
//
//  Created by 조우현 on 4/24/25.
//

import SwiftUI

struct TabBarView: View {
    
    @State private var selectedTab: Tab = .today
    @State private var networkMonitor = NetworkMonitor.shared
    @State private var showAlert = false
    let realmRepo: RealmRepositoryType
    
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
        .onReceive(networkMonitor.$isConnected) { isConnected in
            showAlert = !isConnected
            if !isConnected {
                realmRepo.pauseAllDownloadsOnNetworkDisconnect()
            }
        }
        .alert("네트워크 연결이 끊겼습니다. Wifi나 셀룰러 데이터를 확인해주세요.", isPresented: $showAlert) {
            Button("설정으로 이동", role: .cancel) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}

#Preview {
    TabBarView(realmRepo: RealmRepository.shared)
}
