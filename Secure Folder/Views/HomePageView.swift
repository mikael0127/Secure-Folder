//
//  homePageView.swift
//  Secure Folder
//
//  Created by Mikael Denys Wijaya on 14/06/23.
//
//


import SwiftUI

struct HomePageView: View {
    @AppStorage("isLocked") private var isLocked = true // Use @AppStorage to persist the isLocked value
    let password = "MySecurePassword123"

    init() {
        FolderManager.createFolderStructure()
        isLocked = !FolderManager.isDecryptedFolderPresent()
    }

    var body: some View {
        NavigationView {
            if isLocked {
                lockedView() // Display locked view if folder is locked
                    .navigationBarHidden(true)
            } else {
                unlockedView() // Display unlocked view if folder is unlocked
            }
        }
    }

    // View displayed when folder is locked
    func lockedView() -> some View {
        VStack {
            Image(systemName: "lock.fill")
                .font(.system(size: 80))
                .foregroundColor(.red)
                .padding()
            Text("Folder is locked")
                .font(.title)
                .fontWeight(.semibold)
                .padding()
            Button(action: {
                isLocked.toggle() // Unlock the folder
                if !isLocked {
                    decryptDocumentsFolder(withPassword: password) // Decrypt the folder when unlocking
                }
            }) {
                Text("Unlock")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }

    // View displayed when folder is unlocked
    func unlockedView() -> some View {
        TabView {
            NavigationView {
                List {
                    Section {
                        NavigationLink(destination: PhotoView()) {
                            SettingsRowView(imageName: "photo",
                                            title: "Photos",
                                            tintColor:.blue)
                        }

                        NavigationLink(destination: VideoView()) {
                            SettingsRowView(imageName: "video",
                                            title: "Videos",
                                            tintColor:.blue)
                        }

                        NavigationLink(destination: DocumentView()) {
                            SettingsRowView(imageName: "doc",
                                            title: "Documents",
                                            tintColor:.blue)
                        }

                        NavigationLink(destination: ContactListView()) {
                            SettingsRowView(imageName: "person.crop.circle.fill",
                                            title: "Contacts",
                                            tintColor:.blue)
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
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // Lock button in the top-right corner
    var lockButton: some View {
        Button(action: {
            isLocked.toggle() // Lock or unlock the folder
            if isLocked {
                encryptDocumentsFolder(withPassword: password) // Encrypt the folder when locking
            } else {
                decryptDocumentsFolder(withPassword: password) // Decrypt the folder when unlocking
            }
        }) {
            Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
                .font(.title)
                .imageScale(.medium)
        }
        .padding(.trailing)
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}

