//
//  MyAppView.swift
//  Appventure
//
//  Created by 조우현 on 4/25/25.
//

import SwiftUI

struct MyAppView: View {
    @StateObject var viewModel: MyAppViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("MyApp")
            }
            .navigationTitle("앱")
        }
    }
}

#Preview {
    MyAppView(
        viewModel: MyAppViewModel(
            networkRepo: ItunesRepository.shared,
            realmRepo: RealmRepository.shared
        )
    )
}
