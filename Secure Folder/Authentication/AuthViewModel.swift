//
//  AuthViewModel.swift
//  Secure Folder
//
//  Created by Mikael Denys Widjaja on 10/06/23.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift
import Security

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var authError: AuthError?
    @Published var showAlert = false
    @Published var isLoading = false
    
    // to check if the user is current logged in
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            isLoading = true
            await fetchUser()
            isLoading = false
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        isLoading = true
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
            isLoading = false
        } catch {
            let authError = AuthErrorCode.Code(rawValue: (error as NSError).code)
            self.showAlert = true
            self.authError = AuthError(authErrorCode: authError ?? .userNotFound)
            isLoading = false
        }
    }

    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        isLoading = true
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            // Generate key pair
            let keyPair = try generateKeyPair()
            
            // Save public key in Firebase database
            let publicKeyData = try PublicKeyContainer(publicKey: keyPair.publicKey).encodedData()
            guard let encodedUser = try? Firestore.Encoder().encode(User(id: result.user.uid, fullname: fullname, email: email, publicKey: publicKeyData)) else {
                return
            }
            try await Firestore.firestore().collection("users").document(result.user.uid).setData(encodedUser)
            
            // Save private key in Keychain
            let privateKeyData = try privateKeyDataToKeychainData(keyPair.privateKey)
            try savePrivateKeyToKeychain(privateKeyData)
            
            // Print keys
            let publicKeyString = publicKeyData.base64EncodedString(options: [])
            let privateKeyString = privateKeyData.base64EncodedString(options: [])
            //print("Public Key: \(publicKeyString)")
            //print("Private Key: \(privateKeyString)")
            
            await fetchUser()
            isLoading = false
        } catch {
            let authError = AuthErrorCode.Code(rawValue: (error as NSError).code)
            
            switch authError {
            case .emailAlreadyInUse: // Check for emailAlreadyInUse
                self.showAlert = true
                self.authError = .userExists
            default:
                self.showAlert = true
                self.authError = AuthError(authErrorCode: authError ?? .userNotFound)
            }
            
            isLoading = false
        }
    }
    
    func signOut(_ isLocked: Bool) {
        Task {
            do {
                guard let publicKey = try? await getPublicKey() else {
                    return
                }
                // Check if the MainFolder is locked or not before signing out
                if isLocked {
                    try Auth.auth().signOut() // signs out user on backend
                    self.userSession = nil // wipes out user session and takes us back to login screen
                    self.currentUser = nil // wipes out current user data model
                } else {
                    try? encryptDocumentsFolder(withPublicKey: publicKey)
                    try Auth.auth().signOut() // signs out user on backend
                    self.userSession = nil // wipes out user session and takes us back to login screen
                    self.currentUser = nil // wipes out current user data model
                }
            } catch {
                print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
            }
        }
    }
    
    func deleteAccount() async throws {
        do {
            try await Auth.auth().currentUser?.delete()
            deleteUserData()
            self.currentUser = nil
            self.userSession = nil
        } catch {
            print("DEBUG: Failed to delete account with error \(error.localizedDescription)")
        }
    }
    
    func sendResetPasswordLink(toEmail email: String) {
        Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument()
        guard let user = try? snapshot?.data(as: User.self) else { return }
        self.currentUser = user
    }
    
    func deleteUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).delete()
    }
    
    func changePassword(currentPassword: String, newPassword: String, confirmPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
            return
        }
        
        // Validate new password and confirm password match
        guard newPassword == confirmPassword else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Passwords don't match"])))
            return
        }
        
        // Reauthenticate the user with their current password
        let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: currentPassword)
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                // Change the password
                user.updatePassword(to: newPassword) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }
}

struct PublicKeyContainer {
    let publicKey: SecKey

    func encodedData() throws -> Data {
        var error: Unmanaged<CFError>?
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            throw error?.takeRetainedValue() ?? EncryptionError.keyGenerationFailed
        }
        return publicKeyData
    }
}

func publicKeyDataFromKey(_ publicKey: SecKey) throws -> Data {
    let query: [String: Any] = [
        kSecValueRef as String: publicKey,
        kSecReturnData as String: true
    ]
    
    var publicKeyData: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &publicKeyData)
    
    if status != errSecSuccess {
        throw EncryptionError.keyGenerationFailed
    }
    
    guard let data = publicKeyData as? Data else {
        throw EncryptionError.keyGenerationFailed
    }
    
    return data
}

func privateKeyDataToKeychainData(_ privateKey: SecKey) throws -> Data {
    var error: Unmanaged<CFError>?
    guard let keyData = SecKeyCopyExternalRepresentation(privateKey, &error) as Data? else {
        throw error?.takeRetainedValue() ?? EncryptionError.keyGenerationFailed
    }
    return keyData
}

func savePrivateKeyToKeychain(_ privateKeyData: Data) {
    let privateKeyTag = "user.privateKeyTag" 

    let query: [String: Any] = [
        kSecClass as String: kSecClassKey,
        kSecAttrApplicationTag as String: privateKeyTag,
        kSecAttrKeyType as String: kSecAttrKeyTypeRSA
    ]

    let updateAttributes: [String: Any] = [
        kSecValueData as String: privateKeyData
    ]

    let status = SecItemUpdate(query as CFDictionary, updateAttributes as CFDictionary)

    if status == errSecSuccess {
        print("Private key updated in Keychain successfully.")
    } else if status == errSecItemNotFound {
        var addAttributes = query
        addAttributes[kSecValueData as String] = privateKeyData

        let addStatus = SecItemAdd(addAttributes as CFDictionary, nil)

        if addStatus == errSecSuccess {
            print("Private key stored in Keychain successfully.")
        } else if let error = SecCopyErrorMessageString(addStatus, nil) {
            print("Error saving private key to Keychain: \(error)")
        } else {
            print("Unknown error occurred while saving private key to Keychain.")
        }
    } else if let error = SecCopyErrorMessageString(status, nil) {
        print("Error updating private key in Keychain: \(error)")
    } else {
        print("Unknown error occurred while updating private key in Keychain.")
    }
}

