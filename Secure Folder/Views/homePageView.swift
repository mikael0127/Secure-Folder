//
//  homePageView.swift
//  Secure Folder
//
//  Created by Mikael Denys Wijaya on 14/06/23.
//
//

import SwiftUI
import CryptoKit
import CommonCrypto

struct HomePageView: View {
    @State private var isLocked = true // State variable to track folder lock status
    let password = "MySecurePassword123"

    init() {
        FolderManager.createFolderStructure()
    }

    var body: some View {
        Group {
            if isLocked {
                lockedView() // Display locked view if folder is locked
            } else {
                unlockedView() // Display unlocked view if folder is unlocked
            }
        }
    }

    // View displayed when folder is locked
    func lockedView() -> some View {
        VStack {
            Image(systemName: "lock.fill")
                .font(.system(size: 100))
                .foregroundColor(.red)
                .padding()
            Text("Folder is locked")
                .font(.title)
                .fontWeight(.bold)
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
        Button(action: {
            isLocked.toggle() // Lock the folder
            if isLocked {
                encryptDocumentsFolder(withPassword: password) // Encrypt the folder when locking
            }
        }) {
            Image(systemName: "lock.open.fill")
                .font(.title)
        }
    }

    func encryptDocumentsFolder(withPassword password: String) {
        guard let passwordData = password.data(using: .utf8) else {
            print("Invalid password")
            return
        }

        let salt = "MySalt".data(using: .utf8)! // Convert salt to Data
        let iterations = 10_000 // Number of iterations for key derivation

        // Derive a key using PBKDF2
        guard let derivedKey = deriveKey(passwordData: passwordData, salt: salt, iterations: iterations, keyLength: 32) else {
            print("Error deriving key")
            return
        }

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folderPath = documentsDirectory.appendingPathComponent("MainFolder").path

        do {
            try encryptFolder(atPath: folderPath, withKey: derivedKey)
            print("Folder encryption completed.")
        } catch {
            print("Error encrypting folder: \(error)")
        }
    }

    func decryptDocumentsFolder(withPassword password: String) {
        guard let passwordData = password.data(using: .utf8) else {
            print("Invalid password")
            return
        }

        let salt = "MySalt".data(using: .utf8)! // Convert salt to Data
        let iterations = 10_000 // Number of iterations for key derivation

        // Derive a key using PBKDF2
        guard let derivedKey = deriveKey(passwordData: passwordData, salt: salt, iterations: iterations, keyLength: 32) else {
            print("Error deriving key")
            return
        }

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folderPath = documentsDirectory.appendingPathComponent("MainFolder").path

        do {
            try decryptFolder(atPath: folderPath, withKey: derivedKey)
            print("Folder decryption completed.")
        } catch {
            print("Error decrypting folder: \(error)")
        }
    }

    func deriveKey(passwordData: Data, salt: Data, iterations: Int, keyLength: Int) -> SymmetricKey? {
        var derivedKeyData = Data(count: keyLength)

        let derivationStatus = derivedKeyData.withUnsafeMutableBytes { derivedKeyBytes in
            passwordData.withUnsafeBytes { passwordBytes in
                salt.withUnsafeBytes { saltBytes in
                    CCKeyDerivationPBKDF(
                        CCPBKDFAlgorithm(kCCPBKDF2),
                        passwordBytes.baseAddress?.assumingMemoryBound(to: Int8.self),
                        passwordData.count,
                        saltBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        salt.count,
                        CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                        UInt32(iterations),
                        derivedKeyBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        keyLength
                    )
                }
            }
        }

        guard derivationStatus == kCCSuccess else {
            print("Error deriving key: \(derivationStatus)")
            return nil
        }

        let symmetricKey = SymmetricKey(data: derivedKeyData)
        return symmetricKey
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}



//
//import SwiftUI
//import CryptoKit
//
//struct homePageView: View {
//
//    init() {
//        FolderManager.createFolderStructure()
//    }
//
//    var body: some View {
//
//        TabView {
//            NavigationView {
//                List {
//                    Section {
//                        HStack {
//                            NavigationLink(destination: PhotoView(), label: {
//                                SettingsRowView(imageName: "photo",
//                                                title: "Photos",
//                                                tintColor:.blue)
//                            })
//                        }
//
//                        HStack {
//                            NavigationLink(destination: VideoView(), label: {
//                                SettingsRowView(imageName: "video",
//                                                title: "Videos",
//                                                tintColor:.blue)
//                            })
//                        }
//
//                        HStack {
//                            NavigationLink(destination: DocumentView(), label: {
//                                SettingsRowView(imageName: "doc",
//                                                title: "Documents",
//                                                tintColor:.blue)
//                            })
//                        }
//
//                        HStack {
//                            NavigationLink(destination: ContactListView(), label: {
//                                SettingsRowView(imageName: "person.crop.circle.fill",
//                                                title: "Contacts",
//                                                tintColor:.blue)
//                            })
//
//                        }
//                    }
//                }
//                .navigationBarTitle(Text("Secure Folder").fontWeight(.semibold))
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
//    }
//
//
//    func encryptDocumentsFolder() {
//        guard let password = UserDefaults.standard.string(forKey: "UserPassword") else {
//            print("Password not found in UserDefaults.")
//            return
//        }
//
//        let keyData = password.data(using: .utf8)!
//        let key = SymmetricKey(data: keyData)
//
//        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let folderPath = documentsDirectory.appendingPathComponent("MainFolder").path
//
//        do {
//            try encryptFolder(atPath: folderPath, withKey: key)
//            print("Folder encryption completed.")
//        } catch {
//            print("Error encrypting folder: \(error)")
//        }
//    }
//
//    func decryptDocumentsFolder() {
//        guard let password = UserDefaults.standard.string(forKey: "UserPassword") else {
//            print("Password not found in UserDefaults.")
//            return
//        }
//
//        let keyData = password.data(using: .utf8)!
//        let key = SymmetricKey(data: keyData)
//
//        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let folderPath = documentsDirectory.appendingPathComponent("MainFolder").path
//
//        do {
//            try decryptFolder(atPath: folderPath, withKey: key)
//            print("Folder decryption completed.")
//        } catch {
//            print("Error decrypting folder: \(error)")
//        }
//    }
//
//}
//
//
//struct homePageView_Previews: PreviewProvider {
//    static var previews: some View {
//        homePageView()
//    }
//}
