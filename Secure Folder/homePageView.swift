//
//  NavbarView.swift
//  Secure Folder
//
//  Created by Mikael Denys Wijaya on 14/06/23.
//

import SwiftUI
import PhotosUI

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
                                        NavigationLink(destination: PhotoView(), label: {
                                            SettingsRowView(imageName: "photo",
                                                            title: "Photos",
                                                            tintColor:.blue)
                                        })
                                    }
                                    
                                    HStack {
                                        NavigationLink(destination: VideoView(), label: {
                                            SettingsRowView(imageName: "video",
                                                            title: "Videos",
                                                            tintColor:.blue)
                                        })
                                    }
                                    
                                    HStack {
                                        NavigationLink(destination: DocumentView(), label: {
                                            SettingsRowView(imageName: "doc",
                                                            title: "Documents",
                                                            tintColor:.blue)
                                        })
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
                    }
                    .tabItem {
                        Image(systemName: "person")
                        Text("Profile")
                    }
                    
//                    NavigationView {
//                        Text("Settings Page")
//                            .navigationBarTitle("Settings")
//                    }
//                    .tabItem {
//                        Image(systemName: "gear")
//                        Text("Settings")
//                    }
                }
    }
}

struct homePageView_Previews: PreviewProvider {
    static var previews: some View {
        homePageView()
    }
}
