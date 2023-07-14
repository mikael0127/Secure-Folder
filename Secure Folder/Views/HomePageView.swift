//
//  homePageView.swift
//  Secure Folder
//
//  Created by Mikael Denys Wijaya on 14/06/23.
//
//
//
// Original Implementation, with asking password to unlock
//import SwiftUI
//import Security
//
//struct HomePageView: View {
//    // Use @AppStorage to persist the isLocked value
//    @AppStorage("isLocked") private var isLocked = true
//    @AppStorage("isPasswordCreated") private var isPasswordCreated = false
//    @State private var password = ""
//    @State private var passwordInKeychain: String = ""
//    @State private var isFolderStateInitialized = false
//    @State private var showAlert = false
//
//    init() {
//        if let storedPassword = getPasswordFromKeychain() {
//            passwordInKeychain = storedPassword
//        }
//    }
//
//    private func initializeFolderState() {
//        guard !isFolderStateInitialized else { return } // Check if folder state is already initialized
//
//        let isMainFolderPresent = FolderManager.isMainFolderPresent()
//        let isEncryptedFolderPresent = FolderManager.isEncryptedFolderPresent()
//
//        if isMainFolderPresent {
//            isLocked = false // Set isLocked to false if "MainFolder" exists
//            print("MainFolder Present")
//        } else if isEncryptedFolderPresent {
//            isLocked = true // Set isLocked to true if "MainFolder.encrypted" exists
//            print("MainFolder.encrypted Present")
//        } else {
//            FolderManager.createFolderStructure()
//            isLocked = false // Set isLocked to false after creating the folder structure
//        }
//
//        isFolderStateInitialized = true // Mark the folder state as initialized
//    }
//
//    var body: some View {
//        Group {
//            if !isPasswordCreated {
//                CreatePasswordInAppView(isPasswordCreated: $isPasswordCreated)
//                    .navigationBarHidden(true)
//            } else if isLocked {
//                lockedTabView()
//                    .navigationBarHidden(true)
//            } else {
//                unlockedView()
//            }
//        }
//        .onAppear {
//            initializeFolderState() // Call initializeFolderState() when the view appears
//        }
//    }
//
//
//    // Locked and unlocked view combined
//    func lockedTabView() -> some View {
//        TabView {
//            NavigationView {
//                VStack {
//                    Image(systemName: "lock.fill")
//                        .font(.system(size: 80))
//                        .foregroundColor(.red)
//                        .padding()
//
//                    Text("Folder is locked")
//                        .font(.title)
//                        .fontWeight(.semibold)
//                        .padding()
//
//                    InputView(text: $password,
//                              title: "Password",
//                              placeholder: "Enter your password",
//                              isSecureField: true)
//                        .autocapitalization(.none)
//                        .padding(.horizontal)
//
//                    Button(action: {
//                        if let storedPassword = getPasswordFromKeychain(), password == storedPassword {
//                            isLocked.toggle() // Unlock the folder
//                            if !isLocked {
//                                decryptDocumentsFolder(withPassword: passwordInKeychain) // Decrypt the folder when unlocking
//                            }
//                            password = "" // Reset the password to an empty string
//                        } else {
//                            // Show the pop-up alert for incorrect password
//                            showAlert = true
//                        }
//                    }) {
//                        Text("Unlock")
//                            .font(.title)
//                            .padding()
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                    }
//                    .alert(isPresented: $showAlert) {
//                        Alert(title: Text("Incorrect Password"), message: Text("The entered password is incorrect."), dismissButton: .default(Text("OK")))
//                    }
//                    .padding(.bottom, 20) // Add padding to move the button down
//                    .padding(.top, -10) // Add negative padding to balance the spacing
//
//                    Spacer()
//                }
//                .navigationBarTitle(Text("Secure Folder").fontWeight(.semibold))
//                .toolbar {
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        lockButton
//                    }
//                }
//            }
//            .tabItem {
//                Image(systemName: "house")
//                Text("Home")
//            }
//
//            NavigationView {
//                ProfileView()
//            }
//            .tabItem {
//                Image(systemName: "person")
//                Text("Profile")
//            }
//        }
//        .navigationViewStyle(StackNavigationViewStyle())
//    }
//
//    // View displayed when folder is unlocked
//    func unlockedView() -> some View {
//        TabView {
//            NavigationView {
//                List {
//                    Section {
//                        NavigationLink(destination: PhotoView()) {
//                            SettingsRowView(imageName: "photo",
//                                            title: "Photos",
//                                            tintColor:.blue)
//                        }
//
//                        NavigationLink(destination: VideoView()) {
//                            SettingsRowView(imageName: "video",
//                                            title: "Videos",
//                                            tintColor:.blue)
//                        }
//
//                        NavigationLink(destination: DocumentView()) {
//                            SettingsRowView(imageName: "doc",
//                                            title: "Documents",
//                                            tintColor:.blue)
//                        }
//
//                        NavigationLink(destination: ContactListView()) {
//                            SettingsRowView(imageName: "person.crop.circle.fill",
//                                            title: "Contacts",
//                                            tintColor:.blue)
//                        }
//                    }
//                }
//                .navigationBarTitle(Text("Secure Folder").fontWeight(.semibold))
//                .toolbar {
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        lockButton
//                    }
//                }
//                .navigationBarItems(trailing: deleteButton)
//            }
//            .tabItem {
//                Image(systemName: "house")
//                Text("Home")
//            }
//
//            NavigationView {
//                ProfileView()
//            }
//            .tabItem {
//                Image(systemName: "person")
//                Text("Profile")
//            }
//        }
//        .navigationViewStyle(StackNavigationViewStyle())
//    }
//
//    // Lock button in the top-right corner
//    var lockButton: some View {
//        Button(action: {
//            isLocked.toggle() // Lock or unlock the folder
//            if isLocked {
//                encryptDocumentsFolder(withPassword: passwordInKeychain) // Encrypt the folder when locking
//            } else {
//                decryptDocumentsFolder(withPassword: passwordInKeychain) // Decrypt the folder when unlocking
//            }
//        }) {
//            Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
//                .font(.title)
//                .imageScale(.medium)
//        }
//        .padding(.trailing)
//        .disabled(isLocked) // Disable the lock button when the folder is locked
//    }
//
//    // Delete button
//    var deleteButton: some View {
//        Button(action: {
//            deletePasswordFromKeychain()
//        }) {
//            Image(systemName: "trash")
//        }
//    }
//
//    // Get password from Keychain
//    private func getPasswordFromKeychain() -> String? {
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrAccount as String: "UserPassword",
//            kSecReturnData as String: true
//        ]
//
//        var result: AnyObject?
//        let status = SecItemCopyMatching(query as CFDictionary, &result)
//
//        if status == errSecSuccess {
//            if let data = result as? Data, let password = String(data: data, encoding: .utf8) {
//                print("Retrieved password from Keychain: \(password)") // Print the password
//                return password
//            }
//        }
//
//        return nil
//    }
//
//    // Delete password from keychain
//    private func deletePasswordFromKeychain() {
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrAccount as String: "UserPassword"
//        ]
//
//        let status = SecItemDelete(query as CFDictionary)
//        if status == errSecSuccess {
//            print("Password deleted from Keychain")
//            isPasswordCreated = false // Set isPasswordCreated to false after deleting the password
//        } else {
//            print("Failed to delete password from Keychain. Status: \(status)")
//        }
//    }
//}
//
//struct HomePageView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomePageView()
//    }
//}

// Attempt 1 using hybrid encryption
import SwiftUI
import Security
import Firebase

struct HomePageView: View {
    // Use @AppStorage to persist the isLocked value
    @AppStorage("isLocked") private var isLocked = true
    @State private var isFolderStateInitialized = false
    @State private var showAlert = false
    private let publicKeyTag = "com.example.publicKeyTag"

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
//        let publicKeyTag = "com.example.publicKeyTag" // Update with your public key tag
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
    
    func getPrivateKeyFromKeychain() throws -> SecKey? {
        let privateKeyTag = "user.privateKeyTag" // Update with your private key tag

        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: privateKeyTag,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecReturnRef as String: true
        ]

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess {
            if let privateKeyRef = result {
                let privateKey = unsafeBitCast(privateKeyRef, to: SecKey.self)
                return privateKey
            } else {
                throw KeychainError.retrievalFailed(message: "Failed to retrieve private key.")
            }
        } else if status == errSecItemNotFound {
            throw KeychainError.keyNotFound
        } else if let error = SecCopyErrorMessageString(status, nil) {
            throw KeychainError.retrievalFailed(message: error as String)
        } else {
            throw KeychainError.unknownError
        }
    }


    // Get the private key from Keychain
//    func getPrivateKeyFromKeychain() throws -> SecKey {
//        let privateKeyTag = "com.example.privateKeyTag" // Update with your private key tag
//
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassKey,
//            kSecAttrApplicationTag as String: privateKeyTag,
//            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
//            kSecReturnRef as String: true
//        ]
//
//        var result: CFTypeRef?
//        let status = SecItemCopyMatching(query as CFDictionary, &result)
//
//        if status == errSecSuccess {
//            if let privateKey = result {
//                print("Private Key: \(privateKey)")
//                return privateKey as! SecKey
//            } else {
//                throw KeychainError.retrievalFailed(message: "Failed to retrieve private key.")
//            }
//        } else if status == errSecItemNotFound {
//            throw KeychainError.keyNotFound
//        } else if let error = SecCopyErrorMessageString(status, nil) {
//            throw KeychainError.retrievalFailed(message: error as String)
//        } else {
//            throw KeychainError.unknownError
//        }
//    }
//
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


// Get the private key from Keychain
//    private func getPrivateKey() throws -> SecKey {
//        let privateKeyTag = "com.example.privateKeyTag" // Update with your private key tag
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassKey,
//            kSecAttrApplicationTag as String: privateKeyTag,
//            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
//            kSecReturnRef as String: true
//        ]
//
//        var result: CFTypeRef?
//        let status = SecItemCopyMatching(query as CFDictionary, &result)
//
//        if status != errSecSuccess || result == nil {
//            throw EncryptionError.keyGenerationFailed
//        }
//
//        guard let privateKey = result else {
//            throw EncryptionError.keyGenerationFailed
//        }
//
//        return privateKey as! SecKey
//    }
