//
//  KeyPairGenerationView.swift
//  Secure Folder
//
//  Created by Mikael Denys Widjaja on 9/7/23.
//

// Attempt 1
//import SwiftUI
//
//struct KeyPairGenerationView: View {
//    @State private var publicKey: SecKey?
//    @State private var privateKey: SecKey?
//    @State private var showAlert = false
//
//    var body: some View {
//        VStack {
//            Button("Generate Key Pair") {
//                do {
//                    // Generate the key pair
//                    let (generatedPublicKey, generatedPrivateKey) = try generateKeyPair()
//
//                    // Update the state variables
//                    self.publicKey = generatedPublicKey
//                    self.privateKey = generatedPrivateKey
//
//                    // Show the alert
//                    showAlert = true
//                } catch {
//                    print("Failed to generate key pair: \(error)")
//                }
//            }
//        }
//        .alert(isPresented: $showAlert) {
//            Alert(
//                title: Text("Key Pair Generated"),
//                message: keyPairMessage,
//                dismissButton: .default(Text("OK"))
//            )
//        }
//    }
//
//    private var keyPairMessage: Text {
//        let publicKeyText = publicKey.flatMap(keyToString) ?? ""
//        let privateKeyText = privateKey.flatMap(keyToString) ?? ""
//
//        return Text("Public Key: \(publicKeyText)\nPrivate Key: \(privateKeyText)")
//    }
//
//    private func keyToString(_ key: SecKey) -> String? {
//        var error: Unmanaged<CFError>?
//        guard let keyData = SecKeyCopyExternalRepresentation(key, &error) as Data? else {
//            print("Failed to convert key to data: \(error.debugDescription)")
//            return nil
//        }
//
//        return keyData.base64EncodedString()
//    }
//}
//
//struct KeyPairGenerationView_Previews: PreviewProvider {
//    static var previews: some View {
//        KeyPairGenerationView()
//    }
//}

// Attempt 2
//import SwiftUI
//import Security
//
//struct KeyGenerationView: View {
//    @State private var publicKey: String = ""
//    @State private var privateKey: String = ""
//    @State private var showingAlert = false
//
//    var body: some View {
//        VStack {
//            Button(action: generateKeyPair) {
//                Text("Generate Key Pair")
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .font(.headline)
//                    .cornerRadius(10)
//            }
//        }
//        .alert(isPresented: $showingAlert) {
//            Alert(
//                title: Text("Generated Key Pair"),
//                message: Text("Public Key:\n\(publicKey)\n\nPrivate Key:\n\(privateKey)"),
//                dismissButton: .default(Text("OK"))
//            )
//        }
//    }
//
//    private func generateKeyPair() {
//        do {
//            let (publicKeyData, privateKeyData) = try generateKeyPair()
//            self.publicKey = publicKeyData.base64EncodedString()
//            self.privateKey = privateKeyData.base64EncodedString()
//            showingAlert = true
//        } catch {
//            print("Error generating key pair: \(error)")
//        }
//    }
//
//    private func generateKeyPair() throws -> (Data, Data) {
//        let keyParams: [CFString: Any] = [
//            kSecAttrKeyType: kSecAttrKeyTypeRSA,
//            kSecAttrKeySizeInBits: 2048,
//            kSecPrivateKeyAttrs: [
//                kSecAttrIsPermanent: false,
//                kSecAttrApplicationTag: "com.example.keypair.private".data(using: .utf8)!
//            ] as [CFString: Any]
//        ]
//
//        var error: Unmanaged<CFError>?
//        guard let privateKey = SecKeyCreateRandomKey(keyParams as CFDictionary, &error) else {
//            throw EncryptionError.keyGenerationFailed
//        }
//
//        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
//            throw EncryptionError.keyGenerationFailed
//        }
//
//        let publicKeyData = try exportKeyData(publicKey)
//        let privateKeyData = try exportKeyData(privateKey)
//
//        return (publicKeyData, privateKeyData)
//    }
//
//    private func exportKeyData(_ key: SecKey) throws -> Data {
//        var error: Unmanaged<CFError>?
//        guard let keyData = SecKeyCopyExternalRepresentation(key, &error) as Data?,
//              error == nil else {
//            throw error!.takeRetainedValue() as Error
//        }
//        return keyData
//    }
//}
//
//struct Previews_KeyPairGenerationView_Previews: PreviewProvider {
//    static var previews: some View {
//        KeyGenerationView()
//            .navigationTitle("Key Generation")
//    }
//}
