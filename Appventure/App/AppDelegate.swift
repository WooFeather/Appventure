//
//  AppDelegate.swift
//  Appventure
//
//  Created by 조우현 on 4/27/25.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      
    return true
  }

  // 앱이 완전히 종료되기 직전 호출
  func applicationWillTerminate(_ application: UIApplication) {
    RealmRepository.shared.handleAppWillTerminate()
  }
}
