//
//  ContentView.swift
//  Secure Folder
//
//  Created by Mikael Denys Wijaya on 10/04/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                if isActive {
                    ProfileView()
                } else {
                    VStack {
                        VStack {
                            Image(systemName: "folder.fill")
                                .font(.system(size: 80))
                                .foregroundColor(Color(.systemBlue))
                            Text("Secure Folder")
                                .font(.system( size: 26))
                                .foregroundColor(.black.opacity(0.8))
                        }
                        .scaleEffect(size)
                        .opacity(opacity)
                        .onAppear {
                            withAnimation(.easeIn(duration: 1.2)) {
                                self.size = 0.9
                                self.opacity = 1.0
                            }
                        }
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.isActive = true
                        }
                    }
                }
            } else {
                if isActive {
                    LoginView()
                } else {
                    VStack {
                        VStack {
                            Image(systemName: "folder.fill")
                                .font(.system(size: 80))
                                .foregroundColor(Color(.systemBlue))
                            Text("Secure Folder")
                                .font(.system( size: 26))
                                .foregroundColor(.black.opacity(0.8))
                        }
                        .scaleEffect(size)
                        .opacity(opacity)
                        .onAppear {
                            withAnimation(.easeIn(duration: 1.2)) {
                                self.size = 0.9
                                self.opacity = 1.0
                            }
                        }
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
