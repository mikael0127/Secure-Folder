//
//  AsymmetricEncDec.swift
//  Secure Folder
//
//  Created by Mikael Denys Widjaja on 9/7/23.
//
//

// Attempt 1 asymmetric

//import Foundation
//import Security
//
//func generateKeyPair() throws -> (SecKey, SecKey) {
//    let keyPairParams: [String: Any] = [
//        kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
//        kSecAttrKeySizeInBits as String: 1024
//    ]
//
//    var publicKey, privateKey: SecKey?
//    let status = SecKeyGeneratePair(keyPairParams as CFDictionary, &publicKey, &privateKey)
//
//    guard status == errSecSuccess, let publicKeyUnwrapped = publicKey, let privateKeyUnwrapped = privateKey else {
//        throw KeyGenerationError.keyGenerationFailed
//    }
//
//    return (publicKeyUnwrapped, privateKeyUnwrapped)
//}
//
//
//enum KeyGenerationError: Error {
//    case keyGenerationFailed
//}
//
//func encryptData(data: Data, publicKey: SecKey) throws -> Data {
//    var error: Unmanaged<CFError>?
//    guard let encryptedData = SecKeyCreateEncryptedData(publicKey, .rsaEncryptionOAEPSHA512, data as CFData, &error) as Data? else {
//        if let error = error?.takeRetainedValue() {
//            throw EncryptionError.encryptionFailed(error: error)
//        } else {
//            throw EncryptionError.encryptionFailed(error: nil)
//        }
//    }
//
//    return encryptedData
//}
//
//func encryptFile(fileURL: URL, publicKey: SecKey) throws {
//    let fileData = try Data(contentsOf: fileURL)
//    let encryptedData = try encryptData(data: fileData, publicKey: publicKey)
//    let encryptedFileURL = fileURL.appendingPathExtension("enc")
//    try encryptedData.write(to: encryptedFileURL)
//    print("File encrypted and saved at: \(encryptedFileURL.path)")
//}
//
//func decryptData(encryptedData: Data, privateKey: SecKey) throws -> Data {
//    var error: Unmanaged<CFError>?
//    guard let decryptedData = SecKeyCreateDecryptedData(privateKey, .rsaEncryptionOAEPSHA512, encryptedData as CFData, &error) as Data? else {
//        if let error = error?.takeRetainedValue() {
//            throw DecryptionError.decryptionFailed(error: error)
//        } else {
//            throw DecryptionError.decryptionFailed(error: nil)
//        }
//    }
//
//    return decryptedData
//}
//
//func decryptFile(encryptedFileURL: URL, privateKey: SecKey) throws {
//    let encryptedData = try Data(contentsOf: encryptedFileURL)
//    let decryptedData = try decryptData(encryptedData: encryptedData, privateKey: privateKey)
//    let decryptedFileURL = encryptedFileURL.deletingPathExtension()
//    try decryptedData.write(to: decryptedFileURL)
//    print("File decrypted and saved at: \(decryptedFileURL.path)")
//}
//
//func encryptFolder(folderURL: URL, publicKey: SecKey) throws {
//    let fileManager = FileManager.default
//    let enumerator = fileManager.enumerator(at: folderURL, includingPropertiesForKeys: nil)
//
//    guard let urls = enumerator?.allObjects as? [URL] else {
//        throw EncryptionError.invalidFolderURL
//    }
//
//    for fileURL in urls {
//        if fileURL.hasDirectoryPath {
//            continue // Skip subfolders
//        }
//
//        try encryptFile(fileURL: fileURL, publicKey: publicKey)
//    }
//}
//
//func decryptFolder(encryptedFolderURL: URL, privateKey: SecKey) throws {
//    let fileManager = FileManager.default
//    let enumerator = fileManager.enumerator(at: encryptedFolderURL, includingPropertiesForKeys: nil)
//
//    guard let urls = enumerator?.allObjects as? [URL] else {
//        throw DecryptionError.invalidFolderURL
//    }
//
//    for encryptedFileURL in urls {
//        if encryptedFileURL.hasDirectoryPath || encryptedFileURL.pathExtension != "enc" {
//            continue // Skip subfolders and non-encrypted files
//        }
//
//        try decryptFile(encryptedFileURL: encryptedFileURL, privateKey: privateKey)
//    }
//}
//
//enum EncryptionError: Error {
//    case encryptionFailed(error: Error?)
//    case invalidFolderURL
//}
//
//enum DecryptionError: Error {
//    case decryptionFailed(error: Error?)
//    case invalidFolderURL
//}
//
//
//

// Attempt 2 hybrid encryption (confusing lol)

//import Foundation
//import Security
//import CommonCrypto
//
//func generateKeyPair() throws -> (SecKey, SecKey) {
//    let keyPairParams: [String: Any] = [
//        kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
//        kSecAttrKeySizeInBits as String: 1024
//    ]
//
//    var publicKey, privateKey: SecKey?
//    let status = SecKeyGeneratePair(keyPairParams as CFDictionary, &publicKey, &privateKey)
//
//    guard status == errSecSuccess, let publicKeyUnwrapped = publicKey, let privateKeyUnwrapped = privateKey else {
//        throw KeyGenerationError.keyGenerationFailed
//    }
//
//    return (publicKeyUnwrapped, privateKeyUnwrapped)
//}
//
//
//enum KeyGenerationError: Error {
//    case keyGenerationFailed
//}
//
//enum EncryptionError: Error {
//    case encryptionFailed
//}
//
//enum DecryptionError: Error {
//    case decryptionFailed
//}
//
//// Generate a symmetric encryption key
//func generateSymmetricKey(keySize: Int) -> Data {
//    var keyData = Data(count: keySize / 8)
//    _ = keyData.withUnsafeMutableBytes { mutableBytes in
//        SecRandomCopyBytes(kSecRandomDefault, keySize / 8, mutableBytes.baseAddress!.assumingMemoryBound(to: UInt8.self))
//    }
//    return keyData
//}
//
//// Encrypt data with a symmetric key
//func encryptDataWithSymmetricKey(data: Data, symmetricKey: Data) throws -> Data {
//    let ivSize = kCCBlockSizeAES128
//    var iv = Data(count: ivSize)
//    _ = iv.withUnsafeMutableBytes { mutableBytes in
//        SecRandomCopyBytes(kSecRandomDefault, ivSize, mutableBytes.baseAddress!.assumingMemoryBound(to: UInt8.self))
//    }
//
//    var encryptedData = Data(count: data.count + ivSize)
//    let status = encryptedData.withUnsafeMutableBytes { encryptedBytes in
//        data.withUnsafeBytes { dataBytes in
//            iv.withUnsafeBytes { ivBytes in
//                symmetricKey.withUnsafeBytes { keyBytes in
//                    CCCrypt(
//                        CCOperation(kCCEncrypt),
//                        CCAlgorithm(kCCAlgorithmAES),
//                        CCOptions(kCCOptionPKCS7Padding),
//                        keyBytes.baseAddress,
//                        keyBytes.count,
//                        ivBytes.baseAddress,
//                        dataBytes.baseAddress,
//                        dataBytes.count,
//                        encryptedBytes.baseAddress,
//                        encryptedBytes.count,
//                        nil
//                    )
//                }
//            }
//        }
//    }
//
//    guard status == kCCSuccess else {
//        throw EncryptionError.encryptionFailed
//    }
//
//    return iv + encryptedData
//}
//
//// Decrypt data with a symmetric key
//func decryptDataWithSymmetricKey(encryptedData: Data, symmetricKey: Data) throws -> Data {
//    let ivSize = kCCBlockSizeAES128
//    let iv = encryptedData[..<ivSize]
//    let ciphertext = encryptedData[ivSize...]
//
//    var decryptedData = Data(count: ciphertext.count)
//    let status = decryptedData.withUnsafeMutableBytes { decryptedBytes in
//        ciphertext.withUnsafeBytes { ciphertextBytes in
//            iv.withUnsafeBytes { ivBytes in
//                symmetricKey.withUnsafeBytes { keyBytes in
//                    CCCrypt(
//                        CCOperation(kCCDecrypt),
//                        CCAlgorithm(kCCAlgorithmAES),
//                        CCOptions(kCCOptionPKCS7Padding),
//                        keyBytes.baseAddress,
//                        keyBytes.count,
//                        ivBytes.baseAddress,
//                        ciphertextBytes.baseAddress,
//                        ciphertextBytes.count,
//                        decryptedBytes.baseAddress,
//                        decryptedBytes.count,
//                        nil
//                    )
//                }
//            }
//        }
//    }
//
//    guard status == kCCSuccess else {
//        throw DecryptionError.decryptionFailed
//    }
//
//    return decryptedData
//}
//
//// Encrypt data using hybrid encryption
//func encryptDataHybrid(data: Data, publicKey: SecKey) throws -> Data {
//    // Generate a symmetric key
//    let symmetricKey = generateSymmetricKey(keySize: 256) // Key size in bits
//
//    // Encrypt the data with the symmetric key
//    let encryptedData = try encryptDataWithSymmetricKey(data: data, symmetricKey: symmetricKey)
//
//    // Encrypt the symmetric key with the recipient's public key
//    guard let encryptedSymmetricKey = SecKeyCreateEncryptedData(
//        publicKey,
//        .rsaEncryptionOAEPSHA512,
//        symmetricKey as CFData,
//        nil
//    ) as Data? else {
//        throw EncryptionError.encryptionFailed
//    }
//
//    // Combine the encrypted symmetric key and the encrypted data
//    let combinedData = encryptedSymmetricKey + encryptedData
//
//    return combinedData
//}
//
//// Decrypt data using hybrid decryption
//func decryptDataHybrid(combinedData: Data, privateKey: SecKey) throws -> Data {
//    // Split the combined data into encrypted symmetric key and encrypted data
//    let encryptedSymmetricKey = combinedData[..<256]
//    let encryptedData = combinedData[256...]
//
//    // Decrypt the symmetric key with the private key
//    guard let decryptedSymmetricKey = SecKeyCreateDecryptedData(
//        privateKey,
//        .rsaEncryptionOAEPSHA512,
//        encryptedSymmetricKey as CFData,
//        nil
//    ) as Data? else {
//        throw DecryptionError.decryptionFailed
//    }
//
//    // Decrypt the data with the symmetric key
//    let decryptedData = try decryptDataWithSymmetricKey(
//        encryptedData: encryptedData,
//        symmetricKey: decryptedSymmetricKey
//    )
//
//    return decryptedData
//}
//
//func encryptFileHybrid(fileURL: URL, publicKey: SecKey) throws {
//    let fileData = try Data(contentsOf: fileURL)
//
//    let encryptedData = try encryptDataHybrid(data: fileData, publicKey: publicKey)
//
//    let encryptedFileURL = fileURL.deletingLastPathComponent().appendingPathComponent("EncryptedFiles").appendingPathComponent(fileURL.lastPathComponent)
//
//    try encryptedData.write(to: encryptedFileURL)
//
//    try FileManager.default.removeItem(at: fileURL)
//}
//
//func encryptDirectoryHybrid(directoryURL: URL, publicKey: SecKey) throws {
//    let fileURLs = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
//    for fileURL in fileURLs {
//        if fileURL.hasDirectoryPath {
//            try encryptDirectoryHybrid(directoryURL: fileURL, publicKey: publicKey)
//        } else {
//            try encryptFileHybrid(fileURL: fileURL, publicKey: publicKey)
//        }
//    }
//}
//
//func loadPublicKey() throws -> SecKey {
//    // Replace this with your own logic to load the public key
//    // For example, load from a file or keychain
//    //let publicKey: SecKey = ...
//    return publicKey
//}
//
//func encryptMainFolder() throws {
//    let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//    let mainFolderURL = documentsDirectoryURL.appendingPathComponent("MainFolder")
//
//    let publicKey = try loadPublicKey()
//
//    try encryptDirectoryHybrid(directoryURL: mainFolderURL, publicKey: publicKey)
//}
//
//func decryptFileHybrid(fileURL: URL, privateKey: SecKey) throws {
//    let encryptedData = try Data(contentsOf: fileURL)
//
//    let decryptedData = try decryptDataHybrid(combinedData: encryptedData, privateKey: privateKey)
//
//    let decryptedFileURL = fileURL.deletingLastPathComponent().appendingPathComponent("DecryptedFiles").appendingPathComponent(fileURL.lastPathComponent)
//
//    try decryptedData.write(to: decryptedFileURL)
//
//    try FileManager.default.removeItem(at: fileURL)
//}
//
//func decryptDirectoryHybrid(directoryURL: URL, privateKey: SecKey) throws {
//    let fileURLs = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
//    for fileURL in fileURLs {
//        if fileURL.hasDirectoryPath {
//            try decryptDirectoryHybrid(directoryURL: fileURL, privateKey: privateKey)
//        } else {
//            try decryptFileHybrid(fileURL: fileURL, privateKey: privateKey)
//        }
//    }
//}
//
//func decryptMainFolder() throws {
//    let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//    let encryptedFolderURL = documentsDirectoryURL.appendingPathComponent("EncryptedFiles")
//
//    let privateKey = try loadPrivateKey()
//
//    try decryptDirectoryHybrid(directoryURL: encryptedFolderURL, privateKey: privateKey)
//}
//
//func loadPrivateKey() throws -> SecKey {
//    // Replace this with your own logic to load the private key
//    // For example, load from a file or keychain
//    //let privateKey: SecKey = ...
//    return privateKey
//}

//do {
//    try decryptMainFolder()
//    print("Decryption successful!")
//} catch {
//    print("Decryption failed with error: \(error)")
//}

//// Example usage:
//do {
//    // Generate key pair
//    let (publicKey, privateKey) = try generateKeyPair()
//
//    // Generate some sample data
//    let originalData = "Hello, World!".data(using: .utf8)!
//
//    // Encrypt the data using hybrid encryption
//    let encryptedData = try encryptDataHybrid(data: originalData, publicKey: publicKey)
//
//    //Please note that the code provided is for demonstration purposes only and may not include all necessary error handling or security measures required in a production environment. It's important to carefully consider security implications and follow best practices when implementing encryption algorithms.
//}


// Attempt 3 hybrid encryption
// This function uses the deprecated SecKeyGeneratePair
//func generateKeyPair() throws -> (SecKey, SecKey) {
//    let privateKeyParams: [String: Any] = [
//        kSecAttrIsPermanent as String: false,
//        kSecAttrApplicationTag as String: "com.example.keypair.private".data(using: .utf8)!
//    ]
//
//    let publicKeyParams: [String: Any] = [
//        kSecAttrIsPermanent as String: false,
//        kSecAttrApplicationTag as String: "com.example.keypair.public".data(using: .utf8)!
//    ]
//
//    let keyPairParams: [String: Any] = [
//        kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
//        kSecAttrKeySizeInBits as String: 2048,
//        kSecPrivateKeyAttrs as String: privateKeyParams,
//        kSecPublicKeyAttrs as String: publicKeyParams
//    ]
//
//    var publicKey: SecKey?
//    var privateKey: SecKey?
//
//    let status = SecKeyGeneratePair(keyPairParams as CFDictionary, &publicKey, &privateKey)
//    guard status == errSecSuccess else {
//        throw EncryptionError.keyGenerationFailed
//    }
//
//    guard let publicKey = publicKey, let privateKey = privateKey else {
//        throw EncryptionError.keyGenerationFailed
//    }
//
//    return (publicKey, privateKey)
//}


//import SwiftUI
//import CryptoKit
//import Foundation
//import CommonCrypto
//
//enum EncryptionError: Error {
//    case keyGenerationFailed
//    case invalidSymmetricKey
//}
//
//extension FileManager {
//    func isDirectory(url: URL) -> Bool {
//        var isDirectory: ObjCBool = false
//        return fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
//    }
//}
//
//// This function uses the new SecKeyCreateRandomKey
//func generateKeyPair() throws -> (SecKey, SecKey) {
//    let keyParams: [CFString: Any] = [
//        kSecAttrKeyType: kSecAttrKeyTypeRSA,
//        kSecAttrKeySizeInBits: 2048,
//        kSecPrivateKeyAttrs: [
//            kSecAttrIsPermanent: false,
//            kSecAttrApplicationTag: "com.example.keypair.private".data(using: .utf8)!
//        ] as [CFString : Any]
//    ]
//
//    var error: Unmanaged<CFError>?
//    guard let privateKey = SecKeyCreateRandomKey(keyParams as CFDictionary, &error) else {
//        throw EncryptionError.keyGenerationFailed
//    }
//
//    guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
//        throw EncryptionError.keyGenerationFailed
//    }
//
//    return (publicKey, privateKey)
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
//    var error: Unmanaged<CFError>?
//    guard let encryptedData = SecKeyCreateEncryptedData(publicKey, .rsaEncryptionOAEPSHA512, data as CFData, &error) as Data? else {
//        throw error!.takeRetainedValue() as Error
//    }
//
//    try encryptedData.write(to: destinationURL)
//}
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
//    let combinedData = try Data(contentsOf: sourceURL)
//
//    // Determine the key size
//    let blockSize = SecKeyGetBlockSize(privateKey)
//    let keySize = blockSize - 11 // Account for padding
//
//    // Split the combined data into the encrypted key and the encrypted data
//    let encryptedKey = combinedData.prefix(keySize)
//    let encryptedData = combinedData.suffix(from: keySize)
//
//    // Decrypt the symmetric key with the private key
//    var error: Unmanaged<CFError>?
//    guard let decryptedKeyData = SecKeyCreateDecryptedData(privateKey, .rsaEncryptionOAEPSHA512, encryptedKey as CFData, &error) as Data?,
//        error == nil else {
//            throw EncryptionError.invalidSymmetricKey
//    }
//
//    let symmetricKey = SymmetricKey(data: decryptedKeyData)
//
//    let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
//    let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
//
//    try decryptedData.write(to: destinationURL)
//}
//
//
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
//       try decryptFolder(atPath: encryptedFolderPath, withPrivateKey: privateKey)
//        print("Folder decryption completed.")
//    } catch {
//        print("Error decrypting folder: \(error)")
//    }
//}
