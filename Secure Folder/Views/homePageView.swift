//
//  NavbarView.swift
//  Secure Folder
//
//  Created by Mikael Denys Wijaya on 14/06/23.
//

import SwiftUI
import CryptoKit

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

                        HStack {
                            NavigationLink(destination: ContactListView(), label: {
                                SettingsRowView(imageName: "person.crop.circle.fill",
                                                title: "Contacts",
                                                tintColor:.blue)
                            })

                        }
                    }
                }
                .navigationBarTitle(Text("Secure Folder").fontWeight(.semibold))
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        lockButton
                    }
                }
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
        }
    }
    @ViewBuilder
    private var lockButton: some View {
        Button(action: {
            // Handle lock button tap here
        }) {
            Image(systemName: "lock.fill")
        }
    }
    
    func encryptDocumentsFolder() {
        let key = SymmetricKey(size: .bits256)
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folderPath = documentsDirectory.appendingPathComponent("FolderToEncrypt").path
        
        do {
            try encryptFolder(atPath: folderPath, withKey: key)
            print("Folder encryption completed.")
        } catch {
            print("Error encrypting folder: \(error)")
        }
    }
    
    func decryptDocumentsFolder() {
        let key = SymmetricKey(size: .bits256)
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folderPath = documentsDirectory.appendingPathComponent("FolderToDecrypt").path
        
        do {
            try decryptFolder(atPath: folderPath, withKey: key)
            print("Folder decryption completed.")
        } catch {
            print("Error decrypting folder: \(error)")
        }
    }
}

struct homePageView_Previews: PreviewProvider {
    static var previews: some View {
        homePageView()
    }
}
