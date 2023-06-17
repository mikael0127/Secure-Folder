//
//  NavbarView.swift
//  Secure Folder
//
//  Created by Mikael Denys Wijaya on 14/06/23.
//

import SwiftUI
import PhotosUI

struct homePageView: View {
    // Add a property to store the selected photos
    @State private var selectedPhotos: [UIImage] = []
    
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
                                        Spacer()
                                        
                                        //Image(systemName: "arrow.right")
                                        //    .imageScale(.small)
                                        //    .font(.title)
                                        //    .foregroundColor(.gray)
                                    }
                                    
                                    HStack {
                                        NavigationLink(destination: VideoView(), label: {
                                            SettingsRowView(imageName: "video",
                                                            title: "Videos",
                                                            tintColor:.blue)
                                        })
                                        
                                        Spacer()
                                        
                                        //Image(systemName: "arrow.right")
                                         //   .imageScale(.small)
                                         //   .font(.title)
                                         //   .foregroundColor(.gray)
                                    }
                                    
                                    HStack {
                                        NavigationLink(destination: DocumentView(), label: {
                                            SettingsRowView(imageName: "doc",
                                                            title: "Documents",
                                                            tintColor:.blue)
                                        })
                                        
                                        Spacer()
                                        
                                        //Image(systemName: "arrow.right")
                                          //  .imageScale(.small)
                                            //.font(.title)
                                            //.foregroundColor(.gray)
                                    }
                                
                                    HStack {
                                        Button {
                                            print("Contacts")
                                        } label: {
                                            SettingsRowView(imageName: "person.crop.circle.fill",
                                                            title: "Contacts",
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
