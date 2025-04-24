//
//  ContentView.swift
//  Appventure
//
//  Created by 조우현 on 4/24/25.
//

import SwiftUI

struct ContentView: View {
    
    let repo: ItunesRepositoryType = ItunesRepository.shared
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")

            Button("iTunes API 테스트") {
                Task {
                    do {
                        let result = try await repo.lookup(id: 990571676)
                        print(result.results[0].name)
                    } catch {
                        throw error
                    }
                    
                }
            }
        }
        .padding()
    }

//    func fetchItunesAppList() async {
//        let router = ItunesRouter.search(term: "먹캣", offset: 0)
//        
//        do {
//            let dto: AppInfoDTO = try await NetworkManager.shared.fetchData(router)
//            print("✅ 성공! 앱 개수: \(dto.resultCount)")
//            dto.results.forEach { app in
//                print("• \(app.trackName) (\(app.bundleID))")
//            }
//        } catch let error as NetworkError {
//            print("❌ NetworkError: \(error.errorDescription ?? "정의되지 않은 오류")")
//        } catch {
//            print("❌ 알 수 없는 오류: \(error.localizedDescription)")
//        }
//    }
}

#Preview {
    ContentView()
}
