//
//  homePageView.swift
//  Secure Folder
//
//  Created by Mikael Denys Wijaya on 14/06/23.
//
//

import SwiftUI
// Current issue is that when you go to any page and go back to homepage the lockbutton disappears

struct HomePageView: View {
    @State private var isLocked = true // State variable to track folder lock status
    let password = "MySecurePassword123"

    init() {
        FolderManager.createFolderStructure()
    }

    var body: some View {
        NavigationView {
            Group {
                if isLocked {
                    lockedView() // Display locked view if folder is locked
                } else {
                    unlockedView() // Display unlocked view if folder is unlocked
                }
            }
            .navigationBarHidden(true)
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
                .navigationBarItems(trailing: lockButton) // Add lock button to the navigation bar
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
    // Lock button in the top-right corner
    var lockButton: some View {
        HStack {
            Spacer() // Add a spacer to push the button to the right
            Button(action: {
                isLocked.toggle() // Lock the folder
                if isLocked {
                    encryptDocumentsFolder(withPassword: password) // Encrypt the folder when locking
                }
            }) {
                Image(systemName: "lock.open.fill")
                    .font(.title)
                    .imageScale(.medium)
            }
            .padding(.trailing)
            .padding(.top, 90)
        }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}
