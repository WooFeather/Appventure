//
//  AppDetailView.swift
//  Appventure
//
//  Created by 조우현 on 4/25/25.
//

import SwiftUI

struct AppDetailView: View {
    @StateObject var viewModel: AppDetailViewModel
    var appId: Int
    
    var body: some View {
        VStack {
            Text(viewModel.output.app?.name ?? "")
        }
        .onAppear {
            viewModel.action(.fetchApp(appId))
        }
    }
}

#Preview {
    AppDetailView(viewModel: AppDetailViewModel(repository: ItunesRepository.shared), appId: 1464496236)
}
