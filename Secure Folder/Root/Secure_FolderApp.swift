//
//  Secure_FolderApp.swift
//  Secure Folder
//
//  Created by Mikael Denys Wijaya on 10/04/23.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct Secure_FolderApp: App {
    @StateObject var viewModel = AuthViewModel()
    @StateObject var inactivityTimerManager = InactivityTimerManager()
    @StateObject var lockManager = LockManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(inactivityTimerManager)
                .environmentObject(lockManager)
        }
    }
}
