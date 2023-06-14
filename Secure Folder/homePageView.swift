//
//  NavbarView.swift
//  Secure Folder
//
//  Created by Mikael Denys Wijaya on 14/06/23.
//

import SwiftUI

struct homePageView: View {
        
    init() {
        FolderManager.createFolderStructure()
    }
    
    var body: some View {
        
        
        TabView {
                    NavigationView {
                        List {
                            Section {
                                    HStack {
                                        Button {
                                            print("Photos")
                                        } label: {
                                            SettingsRowView(imageName: "photo",
                                                            title: "Photos",
                                                            tintColor:.blue)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "arrow.right")
                                            .imageScale(.small)
                                            .font(.title)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    HStack {
                                        Button {
                                            print("Video")
                                        } label: {
                                            SettingsRowView(imageName: "video",
                                                            title: "Videos",
                                                            tintColor:.blue)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "arrow.right")
                                            .imageScale(.small)
                                            .font(.title)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    HStack {
                                        Button {
                                            print("Document")
                                        } label: {
                                            SettingsRowView(imageName: "doc",
                                                            title: "Documents",
                                                            tintColor:.blue)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "arrow.right")
                                            .imageScale(.small)
                                            .font(.title)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .navigationBarTitle(Text("Secure Folder").fontWeight(.semibold))
                    }
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    
                    NavigationView {
                        ProfileView()
                            .navigationBarTitle(Text("Profile").fontWeight(.semibold))
                    }
                    .tabItem {
                        Image(systemName: "person")
                        Text("Profile")
                    }
                    
                    NavigationView {
                        Text("Settings Page")
                            .navigationBarTitle("Settings")
                    }
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                }
    }
}

struct homePageView_Previews: PreviewProvider {
    static var previews: some View {
        homePageView()
    }
}
