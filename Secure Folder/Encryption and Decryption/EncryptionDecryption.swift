//
//  EncryptionDecryption.swift
//  Secure Folder
//
//  Created by Mikael Denys Wijaya on 23/06/23.
//


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

func encryptFolder(atPath path: String, withKey key: SymmetricKey, publicKey: SecKey) throws {
    let fileManager = FileManager.default
    let folderURL = URL(fileURLWithPath: path)
    // Get the URLs of all files and directories within the folder
    let fileURLs = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)

    for fileURL in fileURLs {
        // Check if the URL represents a directory
        if fileManager.isDirectory(url: fileURL) {
            // Recursively encrypt subfolders
            try encryptFolder(atPath: fileURL.path, withKey: key, publicKey: publicKey)
        } else {
            // Encrypt individual file
            // Create a new URL for the encrypted file
            let encryptedFileURL = fileURL.appendingPathExtension("encrypted")
            // Encrypt the file using the specified symmetric key
            try encryptFile(atPath: fileURL.path, toPath: encryptedFileURL.path, withKey: key)

            // Encrypt the symmetric key with the recipient's public key
            let encryptedKeyData = try encryptData(key.withUnsafeBytes { Data($0) }, publicKey: publicKey)

            // Combine the encrypted symmetric key and the encrypted data into a single Data object
            var combinedData = Data()
            combinedData.append(encryptedKeyData)
            combinedData.append(try Data(contentsOf: encryptedFileURL))

            // Write the combined encrypted data (including the symmetric key) to the .encrypted file
            try combinedData.write(to: encryptedFileURL)

            // Remove the original unencrypted file
            try fileManager.removeItem(at: fileURL)
        }
    }
    // Move the entire folder to a new location with the "encrypted" extension
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
    //print("Data to encrypt:", data)
    let algorithm = SecKeyAlgorithm.rsaEncryptionOAEPSHA512
    guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
        throw EncryptionError.algorithmNotSupported
    }

    var error: Unmanaged<CFError>?
    guard let encryptedData = SecKeyCreateEncryptedData(publicKey, algorithm, data as CFData, &error) as Data? else {
        throw error?.takeRetainedValue() ?? EncryptionError.keyGenerationFailed
    }
    //print("Encrypted data:", encryptedData)
    return encryptedData
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

            // Read the encrypted data (including the encrypted symmetric key) from the .encrypted file
            let encryptedData = try Data(contentsOf: fileURL)

            // Separate the encrypted symmetric key and the encrypted data from the combined encrypted data
            let encryptedKeyData = encryptedData.prefix(256) // Assuming the RSA encrypted key is 256 bytes (2048 bits)

            // Decrypt the symmetric key using the recipient's private key
            let decryptedKeyData = try decryptData(encryptedKeyData, privateKey: privateKey)
            let symmetricKey = try SymmetricKey(data: decryptedKeyData)

            // Decrypt the actual data within the file using the decrypted symmetric key
            let encryptedFileData = encryptedData.suffix(from: 256) // Remove the RSA encrypted key part
            let decryptedData = try ChaChaPoly.open(ChaChaPoly.SealedBox(combined: encryptedFileData), using: symmetricKey)

            // Write the decrypted data to the new file (without the .encrypted extension)
            try decryptedData.write(to: decryptedFileURL)

            // Remove the original encrypted file
            try fileManager.removeItem(at: fileURL)
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
    //print("Sealed Box:", sealedBox)

    let decryptedData = try ChaChaPoly.open(sealedBox, using: key)
    //print("Decrypted Data:", decryptedData)

    try decryptedData.write(to: destinationURL)
}

func decryptData(_ encryptedData: Data, privateKey: SecKey) throws -> Data {
    //print("Data to decrypt:", encryptedData)
    let algorithm = SecKeyAlgorithm.rsaEncryptionOAEPSHA512
    guard SecKeyIsAlgorithmSupported(privateKey, .decrypt, algorithm) else {
        throw EncryptionError.algorithmNotSupported
    }

    var error: Unmanaged<CFError>?
    guard let decryptedData = SecKeyCreateDecryptedData(privateKey, algorithm, encryptedData as CFData, &error) as Data? else {
        throw error?.takeRetainedValue() ?? EncryptionError.keyGenerationFailed
    }
    //print("Decrypted data:", decryptedData)
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



