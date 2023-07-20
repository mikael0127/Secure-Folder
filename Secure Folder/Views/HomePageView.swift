//
//  homePageView.swift
//  Secure Folder
//
//  Created by Mikael Denys Wijaya on 14/06/23.
//
//
//


import SwiftUI
import Security
import Firebase

struct HomePageView: View {
    // Use @AppStorage to persist the isLocked value
    @AppStorage("isLocked") private var isLocked = true
    @State private var isFolderStateInitialized = false
    @State private var showAlert = false

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
        
        let isPrivateKeyStored = isPrivateKeyStoredInKeychain()     // To check if private key is saved or not
        print("Is private key stored in Keychain? \(isPrivateKeyStored)")
    }

    var body: some View {
        Group {
            if isLocked {
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

                    Button(action: {
                        isLocked.toggle() // Unlock the folder
                        if !isLocked {
                            do {
                                if let privateKey = try getPrivateKeyFromKeychain() {
                                    decryptDocumentsFolder(withPrivateKey: privateKey)
                                } else {
                                    // Handle the case when private key is nil (not found in Keychain)
                                    showAlert = true // Set a flag to show an error alert
                                }
                            } catch {
                                // Handle other errors from getPrivateKeyFromKeychain
                                print("Error: \(error)")
                                showAlert = true // Set a flag to show an error alert
                            }
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
                        Alert(
                            title: Text("Error"),
                            message: Text("Failed to retrieve private key."),
                            dismissButton: .default(Text("OK"))
                        )
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
                                            tintColor: .blue)
                        }

                        NavigationLink(destination: VideoView()) {
                            SettingsRowView(imageName: "video",
                                            title: "Videos",
                                            tintColor: .blue)
                        }

                        NavigationLink(destination: DocumentView()) {
                            SettingsRowView(imageName: "doc",
                                            title: "Documents",
                                            tintColor: .blue)
                        }

                        NavigationLink(destination: ContactListView()) {
                            SettingsRowView(imageName: "person.crop.circle.fill",
                                            title: "Contacts",
                                            tintColor: .blue)
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
            Task {
                do {
                    if isLocked {
                        let publicKey = try await getPublicKey()
                        try? encryptDocumentsFolder(withPublicKey: publicKey)
                    } else {
                        if let privateKey = try getPrivateKeyFromKeychain() {
                            try? decryptDocumentsFolder(withPrivateKey: privateKey)
                        } else {
                            // Handle the case when private key is nil (not found in Keychain)
                            showAlert = true // Set a flag to show an error alert
                        }
                    }
                } catch {
                    showAlert = true
                    print("Error: \(error)")
                }
            }
        }) {
            Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
                .font(.title)
                .imageScale(.medium)
        }
        .padding(.trailing)
        .disabled(isLocked) // Disable the lock button when the folder is locked
    }
    
    // Get the public key from Firestore
    private func getPublicKey() async throws -> SecKey {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw EncryptionError.keyGenerationFailed
        }
        
        let documentSnapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
        let user = try documentSnapshot.data(as: User.self)
        
        if !user.publicKey.isEmpty {
            let publicKey = try publicKeyFromData(user.publicKey)
            return publicKey
        } else {
            throw EncryptionError.keyGenerationFailed
        }
    }

    // Convert public key data to SecKey
    private func publicKeyFromData(_ publicKeyData: Data) throws -> SecKey {
        let keyDict: [NSObject: NSObject] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits: NSNumber(value: 2048), // Update with your key size
            kSecReturnPersistentRef: true as NSObject
        ]
        
        var error: Unmanaged<CFError>?
        guard let publicKey = SecKeyCreateWithData(publicKeyData as CFData, keyDict as CFDictionary, &error) else {
            throw error?.takeRetainedValue() ?? EncryptionError.keyGenerationFailed
        }
        
        return publicKey
    }
    
    // To check if the private key is saved
    func isPrivateKeyStoredInKeychain() -> Bool {
        let privateKeyTag = "user.privateKeyTag" // Update with your private key tag

        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: privateKeyTag,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecReturnAttributes as String: true // Request the key attributes
        ]

        var queryResult: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &queryResult)

        if status == errSecSuccess {
            return true
        } else if status == errSecItemNotFound {
            return false
        } else {
            return false
        }
    }

    func getPrivateKeyFromKeychain() throws -> SecKey? {
        let privateKeyTag = "user.privateKeyTag" // Update with your private key tag

        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: privateKeyTag,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecReturnData as String: true // Return the key data instead of the reference
        ]

        var privateKeyData: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &privateKeyData)

        if status == errSecSuccess {
            if let privateKeyData = privateKeyData as? Data {
                let options: [String: Any] = [
                    kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                    kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
                    kSecAttrKeySizeInBits as String: NSNumber(value: 2048) // Update with your key size
                ]

                var error: Unmanaged<CFError>?
                guard let privateKey = SecKeyCreateWithData(privateKeyData as CFData, options as CFDictionary, &error) else {
                    throw error?.takeRetainedValue() ?? KeychainError.retrievalFailed(message: "Failed to create private key from data.")
                }
                
                return privateKey
            } else {
                throw KeychainError.retrievalFailed(message: "Private key data is invalid.")
            }
        } else if status == errSecItemNotFound {
            throw KeychainError.keyNotFound
        } else if let error = SecCopyErrorMessageString(status, nil) {
            throw KeychainError.retrievalFailed(message: error as String)
        } else {
            throw KeychainError.unknownError
        }
    }

    enum KeychainError: Error {
        case keyNotFound
        case retrievalFailed(message: String)
        case unknownError
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}

