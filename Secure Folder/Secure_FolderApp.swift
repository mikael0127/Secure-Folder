//
//  Secure_FolderApp.swift
//  Secure Folder
//
//  Created by Mikael Denys Wijaya on 10/04/23.
//

import SwiftUI
import Firebase

@main
struct Secure_FolderApp: App {
    @StateObject var viewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(viewModel)
        }
    }
}
