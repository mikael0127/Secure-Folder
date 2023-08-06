//
//  HomePageView.swift
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
    @State private var alertMessage = ""
    
    @State private var isPhotosFolderLocked = false
    @State private var isVideosFolderLocked = false
    @State private var isContactsFolderLocked = false
    @State private var isDocumentsFolderLocked = false
    
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
        
        let isEncryptedPhotosFolderPresent = FolderManager.isEncryptedPhotosFolderPresent()
        let isEncryptedVideosFolderPresent = FolderManager.isEncryptedVideosFolderPresent()
        let isEncryptedContactsFolderPresent = FolderManager.isEncryptedContactsFolderPresent()
        let isEncryptedDocumentsFolderPresent = FolderManager.isEncryptedDocumentsFolderPresent()
        
        if isEncryptedPhotosFolderPresent {
            isPhotosFolderLocked = true
        }
        
        if isEncryptedVideosFolderPresent {
            isVideosFolderLocked = true
        }
        
        if isEncryptedContactsFolderPresent {
            isContactsFolderLocked = true
        }
        
        if isEncryptedDocumentsFolderPresent {
            isDocumentsFolderLocked = true
        }
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

    // View displayed when folder is locked
    func lockedTabView() -> some View {
        TabView {
            NavigationView {
                VStack {
                    Spacer()
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
                                    try decryptDocumentsFolder(withPrivateKey: privateKey)
                                    showAlertWithMessage("MainFolder Successfully Unlocked")
                                } else {
                                    // Handle the case when private key is nil (not found in Keychain)
                                    showAlertWithMessage("Error: Failed to retrieve private key.")
                                }
                            } catch {
                                // Handle other errors from getPrivateKeyFromKeychain
                                print("Error: \(error)")
                                showAlertWithMessage("Error: Failed to retrieve private key.")
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
                            title: Text("Success"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    .padding(.bottom, 20) // Add padding to move the button down
                    .padding(.top, -10) // Add negative padding to balance the spacing

                    Spacer()
                }
                .navigationBarTitle("Secure Folder")
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

                        CustomRowView(title: "Photos",
                                      imageName: "photo",
                                      tintColor: .blue,
                                      destination: PhotosView(),
                                      encryptAction: {
                                          Task {
                                              do {
                                                  let publicKey = try await getPublicKey()
                                                  try await encryptPhotosFolder(withPublicKey: publicKey)
                                              } catch {
                                                  print("Error encrypting photos folder:", error)
                                              }
                                          }
                                      },
                                      decryptAction: {
                                            Task {
                                                if let privateKey = try? await getPrivateKeyFromKeychain() {
                                                    do {
                                                        try await decryptPhotosFolder(withPrivateKey: privateKey)
                                                    } catch {
                                                        print("Error decrypting photos folder:", error)
                                                    }
                                                } else {
                                                    print("Private key is nil.")
                                                }
                                            }
                                     },
                                     isLocked: $isPhotosFolderLocked
                                      
                        )
                        .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 13, trailing: 20))
                      
                        
                        CustomRowView(title: "Videos",
                                      imageName: "video",
                                      tintColor: .blue,
                                      destination: VideoView(),
                                      encryptAction: {
                                          Task {
                                              do {
                                                  let publicKey = try await getPublicKey()
                                                  try await encryptVideosFolder(withPublicKey: publicKey)
                                              } catch {
                                                  print("Error encrypting videos folder:", error)
                                              }
                                          }
                                      },
                                      decryptAction: {
                                            Task {
                                                if let privateKey = try? await getPrivateKeyFromKeychain() {
                                                    do {
                                                        try await decryptVideosFolder(withPrivateKey: privateKey)
                                                    } catch {
                                                        print("Error decrypting videos folder:", error)
                                                    }
                                                } else {
                                                    print("Private key is nil.")
                                                }
                                            }
                                      },
                                      isLocked: $isVideosFolderLocked
                        )
                        .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 13, trailing: 20))
                        
                        
                        CustomRowView(title: " Contacts",
                                      imageName: "person.crop.circle.fill",
                                      tintColor: .blue,
                                      destination: ContactListView(),
                                      encryptAction: {
                                          Task {
                                              do {
                                                  let publicKey = try await getPublicKey()
                                                  try await encryptContactsFolder(withPublicKey: publicKey)
                                              } catch {
                                                  print("Error encrypting contacts folder:", error)
                                              }
                                          }
                                      },
                                      decryptAction: {
                                            Task {
                                                if let privateKey = try? await getPrivateKeyFromKeychain() {
                                                    do {
                                                        try await decryptContactsFolder(withPrivateKey: privateKey)
                                                    } catch {
                                                        print("Error decrypting contacts folder:", error)
                                                    }
                                                } else {
                                                    print("Private key is nil.")
                                                }
                                            }
                                      },
                                      isLocked: $isContactsFolderLocked
                        )
                        .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 13, trailing: 20))
                        
                        
                        CustomRowView(title: "  Documents",
                                      imageName: "doc",
                                      tintColor: .blue,
                                      destination: DocumentView(),
                                      encryptAction: {
                                          Task {
                                              do {
                                                  let publicKey = try await getPublicKey()
                                                  try await encryptDocFolder(withPublicKey: publicKey)
                                              } catch {
                                                  print("Error encrypting documents folder:", error)
                                              }
                                          }
                                      },
                                      decryptAction: {
                                            Task {
                                                if let privateKey = try? await getPrivateKeyFromKeychain() {
                                                    do {
                                                        try await decryptDocFolder(withPrivateKey: privateKey)
                                                    } catch {
                                                        print("Error decrypting documents folder:", error)
                                                    }
                                                } else {
                                                    print("Private key is nil.")
                                                }
                                            }
                                      },
                                      isLocked: $isDocumentsFolderLocked
                        )
                        .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 13, trailing: 20))
                    }
                }
                .navigationBarTitle("Secure Folder")
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
    
    typealias FolderOperation = () -> Void
    
    struct CustomRowView<Destination: View>: View {
        let title: String
        let imageName: String
        let tintColor: Color
        let destination: Destination
        let encryptAction: FolderOperation // Closure for encrypting
        let decryptAction: FolderOperation // Closure for decrypting

        @Binding var isLocked: Bool
        @State private var showAlert = false
        @State private var alertMessage = ""

        var body: some View {
            VStack(spacing:0){
                HStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 0) {
                        NavigationLink(destination: destination) {
                            EmptyView() // Set the label to EmptyView to hide the arrow
                        }
                        .disabled(isLocked) // Disable the NavigationLink when locked
                        .opacity(0) // Set opacity to 0 to hide any possible empty space from the hidden arrow

                        SettingsRowView(imageName: imageName, title: title, tintColor: isLocked ? .gray : tintColor)
                            .opacity(isLocked ? 0.5 : 1.0) // Adjust the opacity when locked
                    }

                    Spacer()

                    Button(action: {
                        isLocked.toggle()

                        if isLocked {
                            encryptAction() // Call the encrypt function
                            showAlertWithMessage("\(title) Folder Locked Successfully")
                        } else {
                            decryptAction() // Call the decrypt function
                            showAlertWithMessage("\(title) Folder Unlocked Successfully")
                        }
                    }) {
                        Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
                            .foregroundColor(isLocked ? .red : .blue)
                            .padding(.top, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 3)
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }

        private func showAlertWithMessage(_ message: String) {
            alertMessage = message
            showAlert = true
        }
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
                        showAlertWithMessage("MainFolder Successfully Locked")
                    } else {
                        if let privateKey = try getPrivateKeyFromKeychain() {
                            try? decryptDocumentsFolder(withPrivateKey: privateKey)
                            showAlertWithMessage("MainFolder Successfully Unlocked")
                        } else {
                            // Handle the case when private key is nil (not found in Keychain)
                            showAlertWithMessage("Error: Private key not found.")
                        }
                    }
                } catch {
                    showAlertWithMessage("Error: \(error)")
                }
            }
        }) {
            Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
                .font(.title)
                .imageScale(.medium)
        }
        .padding(.trailing)
        .disabled(isLocked) // Disable the lock button when the folder is locked
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func showAlertWithMessage(_ message: String) {
        alertMessage = message
        showAlert = true
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
