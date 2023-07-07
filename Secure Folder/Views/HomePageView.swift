//
//  homePageView.swift
//  Secure Folder
//
//  Created by Mikael Denys Wijaya on 14/06/23.
//
//

import SwiftUI
import Security

struct HomePageView: View {
    // Use @AppStorage to persist the isLocked value
    @AppStorage("isLocked") private var isLocked = true
    @AppStorage("isPasswordCreated") private var isPasswordCreated = false
    @State private var password = ""
    @State private var passwordInKeychain: String = ""
    @State private var isFolderStateInitialized = false
    @State private var showAlert = false
    
    init() {
        if let storedPassword = getPasswordFromKeychain() {
            passwordInKeychain = storedPassword
        }
    }
    
    private func initializeFolderState() {
        guard !isFolderStateInitialized else { return } // Check if folder state is already initialized
        
        let isMainFolderPresent = FolderManager.isMainFolderPresent()
        let isEncryptedFolderPresent = FolderManager.isEncryptedFolderPresent()

        if isMainFolderPresent {
            isLocked = false // Set isLocked to false if "MainFolder" exists
            print("MainFolder Present")
        } else if isEncryptedFolderPresent {
            isLocked = true // Set isLocked to true if "MainFolder.encrypted" exists
            print("MainFolder.encrypted Present")
        } else {
            FolderManager.createFolderStructure()
            isLocked = false // Set isLocked to false after creating the folder structure
        }
        
        isFolderStateInitialized = true // Mark the folder state as initialized
    }

    var body: some View {
        Group {
            if !isPasswordCreated {
                CreatePasswordInAppView(isPasswordCreated: $isPasswordCreated)
                    .navigationBarHidden(true)
            } else if isLocked {
                lockedTabView()
                    .navigationBarHidden(true)
            } else {
                unlockedView()
            }
        }
        .onAppear {
            initializeFolderState() // Call initializeFolderState() when the view appears
        }
    }


    // Locked and unlocked view combined
    func lockedTabView() -> some View {
        TabView {
            NavigationView {
                VStack {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.red)
                        .padding()
                    
                    Text("Folder is locked")
                        .font(.title)
                        .fontWeight(.semibold)
                        .padding()
                    
                    InputView(text: $password,
                              title: "Password",
                              placeholder: "Enter your password",
                              isSecureField: true)
                        .autocapitalization(.none)
                        .padding(.horizontal)
                    
                    Button(action: {
                        if let storedPassword = getPasswordFromKeychain(), password == storedPassword {
                            isLocked.toggle() // Unlock the folder
                            if !isLocked {
                                decryptDocumentsFolder(withPassword: passwordInKeychain) // Decrypt the folder when unlocking
                            }
                            password = "" // Reset the password to an empty string
                        } else {
                            // Show the pop-up alert for incorrect password
                            showAlert = true
                        }
                    }) {
                        Text("Unlock")
                            .font(.title)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Incorrect Password"), message: Text("The entered password is incorrect."), dismissButton: .default(Text("OK")))
                    }
                    .padding(.bottom, 20) // Add padding to move the button down
                    .padding(.top, -10) // Add negative padding to balance the spacing
                    
                    Spacer()
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
                .navigationBarItems(trailing: deleteButton)
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
                encryptDocumentsFolder(withPassword: passwordInKeychain) // Encrypt the folder when locking
            } else {
                decryptDocumentsFolder(withPassword: passwordInKeychain) // Decrypt the folder when unlocking
            }
        }) {
            Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
                .font(.title)
                .imageScale(.medium)
        }
        .padding(.trailing)
        .disabled(isLocked) // Disable the lock button when the folder is locked
    }
    
    // Delete button
    var deleteButton: some View {
        Button(action: {
            deletePasswordFromKeychain()
        }) {
            Image(systemName: "trash")
        }
    }
    
    // Get password from Keychain
    private func getPasswordFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "UserPassword",
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            if let data = result as? Data, let password = String(data: data, encoding: .utf8) {
                print("Retrieved password from Keychain: \(password)") // Print the password
                return password
            }
        }
        
        return nil
    }
    
    // Delete password from keychain
    private func deletePasswordFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "UserPassword"
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess {
            print("Password deleted from Keychain")
            isPasswordCreated = false // Set isPasswordCreated to false after deleting the password
        } else {
            print("Failed to delete password from Keychain. Status: \(status)")
        }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}
