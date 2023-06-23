//
//  EncryptionDecryption.swift
//  Secure Folder
//
//  Created by Mikael Denys Wijaya on 23/06/23.
//

import SwiftUI
import CryptoKit
import Foundation

extension FileManager {
    func isDirectory(url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        return fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
    }
}

func encryptFile(atPath path: String, withKey key: SymmetricKey) throws {
    let plaintextData = try Data(contentsOf: URL(fileURLWithPath: path))
    let sealedBox = try AES.GCM.seal(plaintextData, using: key)
    
    // Write the encrypted data to a new file
    let encryptedURL = URL(fileURLWithPath: path)
        .deletingPathExtension()
        .appendingPathExtension("encrypted")
    try sealedBox.ciphertext.write(to: encryptedURL)
}

func encryptFolder(atPath path: String, withKey key: SymmetricKey) throws {
    let fileManager = FileManager.default
    
    // Get all files in the folder
    let fileURLs = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: path),
                                                      includingPropertiesForKeys: nil,
                                                      options: [.skipsHiddenFiles])
    
    for fileURL in fileURLs {
        let filePath = fileURL.path
        
        if fileManager.isDirectory(url: fileURL) {
            // Recursively encrypt sub-folders
            try encryptFolder(atPath: filePath, withKey: key)
        } else {
            // Encrypt individual files
            try encryptFile(atPath: filePath, withKey: key)
        }
    }
}

func decryptFile(atPath path: String, withKey key: SymmetricKey) throws {
    let encryptedData = try Data(contentsOf: URL(fileURLWithPath: path))
    let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
    let decryptedData = try AES.GCM.open(sealedBox, using: key)
    
    // Write the decrypted data to a new file
    let decryptedURL = URL(fileURLWithPath: path)
        .deletingPathExtension()
    try decryptedData.write(to: decryptedURL)
}

func decryptFolder(atPath path: String, withKey key: SymmetricKey) throws {
    let fileManager = FileManager.default
    
    // Get all files in the folder
    let fileURLs = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: path),
                                                      includingPropertiesForKeys: nil,
                                                      options: [.skipsHiddenFiles])
    
    for fileURL in fileURLs {
        let filePath = fileURL.path
        
        if fileManager.isDirectory(url: fileURL) {
            // Recursively decrypt sub-folders
            try decryptFolder(atPath: filePath, withKey: key)
        } else {
            // Decrypt individual files
            try decryptFile(atPath: filePath, withKey: key)
        }
    }
}
