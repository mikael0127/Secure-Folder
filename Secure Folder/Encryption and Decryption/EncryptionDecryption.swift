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

extension FileManager {
    func isDirectory(url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        return fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
    }
}

func encryptFolder(atPath path: String, withKey key: SymmetricKey) throws {
    let fileManager = FileManager.default
    let folderURL = URL(fileURLWithPath: path)
    let fileURLs = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)

    for fileURL in fileURLs {
        if fileManager.isDirectory(url: fileURL) {
            try encryptFolder(atPath: fileURL.path, withKey: key)
        }
    }

    let mainFolderURL = URL(fileURLWithPath: path)
    let encryptedFolderURL = mainFolderURL.appendingPathExtension("encrypted")

    try fileManager.moveItem(at: mainFolderURL, to: encryptedFolderURL)
}

func decryptFolder(atPath path: String, withKey key: SymmetricKey) throws {
    let fileManager = FileManager.default
    let folderURL = URL(fileURLWithPath: path)
    let fileURLs = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)

    for fileURL in fileURLs {
        if fileManager.isDirectory(url: fileURL) {
            try decryptFolder(atPath: fileURL.path, withKey: key)
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
    let encryptedFolderPath = documentsDirectory.appendingPathComponent("MainFolder.encrypted").path
    let decryptedFolderPath = documentsDirectory.appendingPathComponent("MainFolder").path

    // Check if the decrypted folder already exists
    if FileManager.default.fileExists(atPath: decryptedFolderPath) {
        print("Decrypted folder already exists.")
        return
    }

    do {
        try decryptFolder(atPath: encryptedFolderPath, withKey: derivedKey)
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


