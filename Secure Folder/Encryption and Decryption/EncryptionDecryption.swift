//
//  EncryptionDecryption.swift
//  Secure Folder
//
//  Created by Mikael Denys Wijaya on 23/06/23.
//

// original implementation using symmetric key cryptography
//import SwiftUI
//import CryptoKit
//import Foundation
//import CommonCrypto
//
//extension FileManager {
//    func isDirectory(url: URL) -> Bool {
//        var isDirectory: ObjCBool = false
//        return fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
//    }
//}
//
//
//func encryptFolder(atPath path: String, withKey key: SymmetricKey) throws {
//    let fileManager = FileManager.default
//    let folderURL = URL(fileURLWithPath: path)
//    let fileURLs = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
//
//    for fileURL in fileURLs {
//        if fileManager.isDirectory(url: fileURL) {
//            try encryptFolder(atPath: fileURL.path, withKey: key)
//        } else {
//            let encryptedFileURL = fileURL.appendingPathExtension("encrypted")
//            try encryptFile(atPath: fileURL.path, toPath: encryptedFileURL.path, withKey: key)
//
//            // Remove the original unencrypted file
//            try fileManager.removeItem(at: fileURL)
//        }
//    }
//
//    let mainFolderURL = URL(fileURLWithPath: path)
//    let encryptedFolderURL = mainFolderURL.appendingPathExtension("encrypted")
//
//    try fileManager.moveItem(at: mainFolderURL, to: encryptedFolderURL)
//}
//
//
//func encryptFile(atPath sourcePath: String, toPath destinationPath: String, withKey key: SymmetricKey) throws {
//    let sourceURL = URL(fileURLWithPath: sourcePath)
//    let destinationURL = URL(fileURLWithPath: destinationPath)
//
//    let data = try Data(contentsOf: sourceURL)
//    let encryptedData = try ChaChaPoly.seal(data, using: key).combined
//
//    try encryptedData.write(to: destinationURL)
//}
//
//
//func decryptFolder(atPath path: String, withKey key: SymmetricKey) throws {
//    let fileManager = FileManager.default
//    let folderURL = URL(fileURLWithPath: path)
//    let fileURLs = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
//
//    for fileURL in fileURLs {
//        if fileManager.isDirectory(url: fileURL) {
//            try decryptFolder(atPath: fileURL.path, withKey: key)
//        } else {
//            let decryptedFileURL = fileURL.deletingPathExtension()
//            try decryptFile(atPath: fileURL.path, toPath: decryptedFileURL.path, withKey: key)
//
//            // Remove the original encrypted file
//            try fileManager.removeItem(at: fileURL)
//        }
//    }
//
//    let encryptedFolderURL = URL(fileURLWithPath: path)
//    let decryptedFolderURL = encryptedFolderURL.deletingPathExtension()
//
//    let tempFolderURL = encryptedFolderURL.appendingPathExtension("temp")
//
//    // Move the decrypted folder to a temporary location
//    try fileManager.moveItem(at: encryptedFolderURL, to: tempFolderURL)
//
//    // Move the decrypted folder from the temporary location to the original location
//    try fileManager.moveItem(at: tempFolderURL, to: decryptedFolderURL)
//}
//
//
//func decryptFile(atPath sourcePath: String, toPath destinationPath: String, withKey key: SymmetricKey) throws {
//    let sourceURL = URL(fileURLWithPath: sourcePath)
//    let destinationURL = URL(fileURLWithPath: destinationPath)
//
//    let encryptedData = try Data(contentsOf: sourceURL)
//    let sealedBox = try ChaChaPoly.SealedBox(combined: encryptedData)
//    let decryptedData = try ChaChaPoly.open(sealedBox, using: key)
//
//    try decryptedData.write(to: destinationURL)
//}
//
//
//func encryptDocumentsFolder(withPassword password: String) {
//    guard let passwordData = password.data(using: .utf8) else {
//        print("Invalid password")
//        return
//    }
//
//    let salt = "MySalt".data(using: .utf8)! // Convert salt to Data
//    let iterations = 10_000 // Number of iterations for key derivation
//
//    // Derive a key using PBKDF2
//    guard let derivedKey = deriveKey(passwordData: passwordData, salt: salt, iterations: iterations, keyLength: 32) else {
//        print("Error deriving key")
//        return
//    }
//
//    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//    let folderPath = documentsDirectory.appendingPathComponent("MainFolder").path
//
//    do {
//        try encryptFolder(atPath: folderPath, withKey: derivedKey)
//        print("Folder encryption completed.")
//    } catch {
//        print("Error encrypting folder: \(error)")
//    }
//}
//
//
//func decryptDocumentsFolder(withPassword password: String) {
//    guard let passwordData = password.data(using: .utf8) else {
//        print("Invalid password")
//        return
//    }
//
//    let salt = "MySalt".data(using: .utf8)! // Convert salt to Data
//    let iterations = 10_000 // Number of iterations for key derivation
//
//    // Derive a key using PBKDF2
//    guard let derivedKey = deriveKey(passwordData: passwordData, salt: salt, iterations: iterations, keyLength: 32) else {
//        print("Error deriving key")
//        return
//    }
//
//    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//    let encryptedFolderPath = documentsDirectory.appendingPathComponent("MainFolder.encrypted").path
//    let decryptedFolderPath = documentsDirectory.appendingPathComponent("MainFolder").path
//
//    // Check if the decrypted folder already exists
//    if FileManager.default.fileExists(atPath: decryptedFolderPath) {
//        print("Decrypted folder already exists.")
//        return
//    }
//
//    do {
//        try decryptFolder(atPath: encryptedFolderPath, withKey: derivedKey)
//        print("Folder decryption completed.")
//    } catch {
//        print("Error decrypting folder: \(error)")
//    }
//}
//
//
//func deriveKey(passwordData: Data, salt: Data, iterations: Int, keyLength: Int) -> SymmetricKey? {
//    var derivedKeyData = Data(count: keyLength)
//
//    let derivationStatus = derivedKeyData.withUnsafeMutableBytes { derivedKeyBytes in
//        passwordData.withUnsafeBytes { passwordBytes in
//            salt.withUnsafeBytes { saltBytes in
//                CCKeyDerivationPBKDF(
//                    CCPBKDFAlgorithm(kCCPBKDF2),
//                    passwordBytes.baseAddress?.assumingMemoryBound(to: Int8.self),
//                    passwordData.count,
//                    saltBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
//                    salt.count,
//                    CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
//                    UInt32(iterations),
//                    derivedKeyBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
//                    keyLength
//                )
//            }
//        }
//    }
//
//    guard derivationStatus == kCCSuccess else {
//        print("Error deriving key: \(derivationStatus)")
//        return nil
//    }
//
//    let symmetricKey = SymmetricKey(data: derivedKeyData)
//    return symmetricKey
//}

// Attempt 1 of hybrid encryption
import SwiftUI
import CryptoKit
import Foundation
import CommonCrypto

enum EncryptionError: Error {
    case algorithmNotSupported
    case keyGenerationFailed
}

extension FileManager {
    func isDirectory(url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        return fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
    }
}

func encryptFolder(atPath path: String, withKey key: SymmetricKey, publicKey: SecKey) throws {
    let fileManager = FileManager.default
    let folderURL = URL(fileURLWithPath: path)
    let fileURLs = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)

    for fileURL in fileURLs {
        if fileManager.isDirectory(url: fileURL) {
            try encryptFolder(atPath: fileURL.path, withKey: key, publicKey: publicKey)
        } else {
            let encryptedFileURL = fileURL.appendingPathExtension("encrypted")
            try encryptFile(atPath: fileURL.path, toPath: encryptedFileURL.path, withKey: key)

            // Encrypt the symmetric key with the recipient's public key
            let encryptedKeyData = try encryptData(key.withUnsafeBytes { Data($0) }, publicKey: publicKey)
            let keyURL = encryptedFileURL.appendingPathExtension("key")
            try encryptedKeyData.write(to: keyURL)

            // Remove the original unencrypted file
            try fileManager.removeItem(at: fileURL)
        }
    }

    let mainFolderURL = URL(fileURLWithPath: path)
    let encryptedFolderURL = mainFolderURL.appendingPathExtension("encrypted")

    try fileManager.moveItem(at: mainFolderURL, to: encryptedFolderURL)
}

func encryptFile(atPath sourcePath: String, toPath destinationPath: String, withKey key: SymmetricKey) throws {
    let sourceURL = URL(fileURLWithPath: sourcePath)
    let destinationURL = URL(fileURLWithPath: destinationPath)

    let data = try Data(contentsOf: sourceURL)
    let sealedBox = try ChaChaPoly.seal(data, using: key)
    let encryptedData = sealedBox.combined

    try encryptedData.write(to: destinationURL)
}

func encryptData(_ data: Data, publicKey: SecKey) throws -> Data {
    let algorithm = SecKeyAlgorithm.rsaEncryptionOAEPSHA512
    guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
        throw EncryptionError.algorithmNotSupported
    }

    var error: Unmanaged<CFError>?
    guard let encryptedData = SecKeyCreateEncryptedData(publicKey, algorithm, data as CFData, &error) as Data? else {
        throw error?.takeRetainedValue() ?? EncryptionError.keyGenerationFailed
    }

    return encryptedData
}

func generateKeyPair() throws -> (privateKey: SecKey, publicKey: SecKey) {
    let attributes: [CFString: Any] = [
        kSecAttrKeyType: kSecAttrKeyTypeRSA,
        kSecAttrKeySizeInBits: 2048
    ]

    var error: Unmanaged<CFError>?
    guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error),
          let publicKey = SecKeyCopyPublicKey(privateKey) else {
        throw error!.takeRetainedValue() as Error
    }

    return (privateKey, publicKey)
}

func decryptFolder(atPath path: String, privateKey: SecKey) throws {
    let fileManager = FileManager.default
    let folderURL = URL(fileURLWithPath: path)
    let fileURLs = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)

    for fileURL in fileURLs {
        if fileManager.isDirectory(url: fileURL) {
            try decryptFolder(atPath: fileURL.path, privateKey: privateKey)
        } else {
            let decryptedFileURL = fileURL.deletingPathExtension()

            // Decrypt the symmetric key using the recipient's private key
            let keyURL = fileURL.appendingPathExtension("key")
            let encryptedKeyData = try Data(contentsOf: keyURL)
            let decryptedKeyData = try decryptData(encryptedKeyData, privateKey: privateKey)
            let symmetricKey = try SymmetricKey(data: decryptedKeyData)

            try decryptFile(atPath: fileURL.path, toPath: decryptedFileURL.path, withKey: symmetricKey)

            // Remove the original encrypted file and key
            try fileManager.removeItem(at: fileURL)
            try fileManager.removeItem(at: keyURL)
        }
    }

    let encryptedFolderURL = URL(fileURLWithPath: path)
    let decryptedFolderURL = encryptedFolderURL.deletingPathExtension()

    let tempFolderURL = encryptedFolderURL.appendingPathExtension("temp")

    // Move the decrypted folder to a temporary location
    try fileManager.moveItem(at: encryptedFolderURL, to: tempFolderURL)

    // Move the decrypted folder from the temporary location to the original location
    try fileManager.moveItem(at: tempFolderURL, to: decryptedFolderURL)
}

func decryptFile(atPath sourcePath: String, toPath destinationPath: String, withKey key: SymmetricKey) throws {
    let sourceURL = URL(fileURLWithPath: sourcePath)
    let destinationURL = URL(fileURLWithPath: destinationPath)

    let encryptedData = try Data(contentsOf: sourceURL)
    let sealedBox = try ChaChaPoly.SealedBox(combined: encryptedData)
    let decryptedData = try ChaChaPoly.open(sealedBox, using: key)

    try decryptedData.write(to: destinationURL)
}

func decryptData(_ encryptedData: Data, privateKey: SecKey) throws -> Data {
    let algorithm = SecKeyAlgorithm.rsaEncryptionOAEPSHA512
    guard SecKeyIsAlgorithmSupported(privateKey, .decrypt, algorithm) else {
        throw EncryptionError.algorithmNotSupported
    }

    var error: Unmanaged<CFError>?
    guard let decryptedData = SecKeyCreateDecryptedData(privateKey, algorithm, encryptedData as CFData, &error) as Data? else {
        throw error?.takeRetainedValue() ?? EncryptionError.keyGenerationFailed
    }

    return decryptedData
}

func decryptDocumentsFolder(withPrivateKey privateKey: SecKey) {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let encryptedFolderPath = documentsDirectory.appendingPathComponent("MainFolder.encrypted").path
    let decryptedFolderPath = documentsDirectory.appendingPathComponent("MainFolder").path

    // Check if the decrypted folder already exists
    if FileManager.default.fileExists(atPath: decryptedFolderPath) {
        print("Decrypted folder already exists.")
        return
    }

    do {
        try decryptFolder(atPath: encryptedFolderPath, privateKey: privateKey)
        print("Folder decryption completed.")
    } catch {
        print("Error decrypting folder: \(error)")
    }
}

func encryptDocumentsFolder(withPublicKey publicKey: SecKey) {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let folderPath = documentsDirectory.appendingPathComponent("MainFolder").path

    do {
        let key = SymmetricKey(size: .bits256)
        try encryptFolder(atPath: folderPath, withKey: key, publicKey: publicKey)
        print("Folder encryption completed.")
    } catch {
        print("Error encrypting folder: \(error)")
    }
}








// Attempt 2 hybrid encryption
//import SwiftUI
//import CryptoKit
//import Foundation
//import CommonCrypto
//
//extension FileManager {
//    func isDirectory(url: URL) -> Bool {
//        var isDirectory: ObjCBool = false
//        return fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
//    }
//}
//
//func generateKeyPair() throws -> (publicKey: SecKey, privateKey: SecKey) {
//    // Define the key attributes
//    let privateKeyParams: [CFString: Any] = [
//        kSecAttrIsPermanent: true
//    ]
//
//    let attributes: [CFString: Any] = [
//        kSecAttrKeyType: kSecAttrKeyTypeRSA,
//        kSecAttrKeySizeInBits: 2048,
//        kSecPrivateKeyAttrs: privateKeyParams
//    ]
//
//    // Generate the key pair using SecKeyCreateRandomKey
//    var error: Unmanaged<CFError>?
//    guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
//        if let error = error?.takeRetainedValue() {
//            throw KeyPairGenerationError.failed(error)
//        }
//        throw KeyPairGenerationError.failed(nil)
//    }
//
//    guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
//        throw KeyPairGenerationError.invalidKeys
//    }
//
//    return (publicKey, privateKey)
//}
//
//enum KeyPairGenerationError: Error {
//    case failed(Error?)
//    case invalidKeys
//}
//
//
//func encryptFolder(atPath path: String, withPublicKey publicKey: SecKey) throws {
//    let fileManager = FileManager.default
//    let folderURL = URL(fileURLWithPath: path)
//    let fileURLs = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
//
//    for fileURL in fileURLs {
//        if fileManager.isDirectory(url: fileURL) {
//            try encryptFolder(atPath: fileURL.path, withPublicKey: publicKey)
//        } else {
//            let encryptedFileURL = fileURL.appendingPathExtension("encrypted")
//            try encryptFile(atPath: fileURL.path, toPath: encryptedFileURL.path, withPublicKey: publicKey)
//
//            // Remove the original unencrypted file
//            try fileManager.removeItem(at: fileURL)
//        }
//    }
//
//    let mainFolderURL = URL(fileURLWithPath: path)
//    let encryptedFolderURL = mainFolderURL.appendingPathExtension("encrypted")
//
//    try fileManager.moveItem(at: mainFolderURL, to: encryptedFolderURL)
//}
//
//func encryptFile(atPath sourcePath: String, toPath destinationPath: String, withPublicKey publicKey: SecKey) throws {
//    let sourceURL = URL(fileURLWithPath: sourcePath)
//    let destinationURL = URL(fileURLWithPath: destinationPath)
//
//    let data = try Data(contentsOf: sourceURL)
//
//    // Generate a symmetric key for file encryption
//    let symmetricKey = SymmetricKey(size: .bits256)
//
//    // Encrypt the file data using the symmetric key
//    let encryptedData = try ChaChaPoly.seal(data, using: symmetricKey).combined
//
//    // Wrap the symmetric key with the recipient's public key
//    var error: Unmanaged<CFError>?
//    guard let wrappedKeyData = SecKeyCreateEncryptedData(publicKey, .rsaEncryptionOAEPSHA256, symmetricKey.withUnsafeBytes({ Data($0) }) as CFData, &error) as Data? else {
//        if let error = error?.takeRetainedValue() {
//            throw error as Error
//        }
//        throw EncryptionError.keyWrapFailed
//    }
//
//    // Write the wrapped symmetric key and encrypted data to the destination file
//    let encryptedFileData = wrappedKeyData + encryptedData
//    try encryptedFileData.write(to: destinationURL)
//}
//
//enum EncryptionError: Error {
//    case keyWrapFailed
//}
//
//
//func decryptFolder(atPath path: String, withPrivateKey privateKey: SecKey) throws {
//    let fileManager = FileManager.default
//    let folderURL = URL(fileURLWithPath: path)
//    let fileURLs = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
//
//    for fileURL in fileURLs {
//        if fileManager.isDirectory(url: fileURL) {
//            try decryptFolder(atPath: fileURL.path, withPrivateKey: privateKey)
//        } else {
//            let decryptedFileURL = fileURL.deletingPathExtension()
//            try decryptFile(atPath: fileURL.path, toPath: decryptedFileURL.path, withPrivateKey: privateKey)
//
//            // Remove the original encrypted file
//            try fileManager.removeItem(at: fileURL)
//        }
//    }
//
//    let encryptedFolderURL = URL(fileURLWithPath: path)
//    let decryptedFolderURL = encryptedFolderURL.deletingPathExtension()
//
//    let tempFolderURL = encryptedFolderURL.appendingPathExtension("temp")
//
//    // Move the decrypted folder to a temporary location
//    try fileManager.moveItem(at: encryptedFolderURL, to: tempFolderURL)
//
//    // Move the decrypted folder from the temporary location to the original location
//    try fileManager.moveItem(at: tempFolderURL, to: decryptedFolderURL)
//}
//
//func decryptFile(atPath sourcePath: String, toPath destinationPath: String, withPrivateKey privateKey: SecKey) throws {
//    let sourceURL = URL(fileURLWithPath: sourcePath)
//    let destinationURL = URL(fileURLWithPath: destinationPath)
//
//    let encryptedFileData = try Data(contentsOf: sourceURL)
//
//    // Extract the wrapped symmetric key and encrypted data
//    let wrappedKeySize = SecKeyGetBlockSize(privateKey)
//    let wrappedKeyData = encryptedFileData.prefix(wrappedKeySize)
//    let encryptedData = encryptedFileData.suffix(from: wrappedKeySize)
//
//    // Unwrap the symmetric key with the private key
//    var error: Unmanaged<CFError>?
//    let unwrappedKeyData = SecKeyCreateDecryptedData(privateKey, .rsaEncryptionOAEPSHA256, wrappedKeyData as CFData, &error) as Data?
//    if let error = error?.takeRetainedValue() {
//        throw error as Error
//    }
//    guard let unwrappedData = unwrappedKeyData else {
//        throw DecryptionError.keyUnwrapFailed
//    }
//
//    // Create a symmetric key from the unwrapped key data
//    let symmetricKey = try SymmetricKey(data: unwrappedData)
//
//    // Decrypt the encrypted data using the symmetric key
//    let sealedBox = try ChaChaPoly.SealedBox(combined: encryptedData)
//    let decryptedData = try ChaChaPoly.open(sealedBox, using: symmetricKey)
//
//    // Write the decrypted data to the destination file
//    try decryptedData.write(to: destinationURL)
//}
//
//enum DecryptionError: Error {
//    case keyUnwrapFailed
//}
//
//// Example usage:
//func encryptDocumentsFolder(withPublicKey publicKey: SecKey) {
//    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//    let folderPath = documentsDirectory.appendingPathComponent("MainFolder").path
//
//    do {
//        try encryptFolder(atPath: folderPath, withPublicKey: publicKey)
//        print("Folder encryption completed.")
//    } catch {
//        print("Error encrypting folder: \(error)")
//    }
//}
//
//func decryptDocumentsFolder(withPrivateKey privateKey: SecKey) {
//    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//    let encryptedFolderPath = documentsDirectory.appendingPathComponent("MainFolder.encrypted").path
//    let decryptedFolderPath = documentsDirectory.appendingPathComponent("MainFolder").path
//
//    // Check if the decrypted folder already exists
//    if FileManager.default.fileExists(atPath: decryptedFolderPath) {
//        print("Decrypted folder already exists.")
//        return
//    }
//
//    do {
//        try decryptFolder(atPath: encryptedFolderPath, withPrivateKey: privateKey)
//        print("Folder decryption completed.")
//    } catch {
//        print("Error decrypting folder: \(error)")
//    }
//}
//
////// Usage:
////// Generate or obtain the public and private keys for encryption and decryption
////let publicKey: SecKey = ... // Public key for encryption
////let privateKey: SecKey = ... // Private key for decryption
////
////// Encrypt the folder using the public key
////encryptDocumentsFolder(withPublicKey: publicKey)
////
////// Decrypt the encrypted folder using the private key
////decryptDocumentsFolder(withPrivateKey: privateKey)
