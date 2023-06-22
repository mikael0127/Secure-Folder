//
//  FolderManager.swift
//  Secure Folder
//
//  Created by Mikael Denys Wijaya on 15/06/23.
//

import Foundation

class FolderManager {
    static func createFolderStructure() {
        let fileManager = FileManager.default
        let mainFolderURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("MainFolder")

        do {
            if !fileManager.fileExists(atPath: mainFolderURL.path) {
                try fileManager.createDirectory(at: mainFolderURL, withIntermediateDirectories: true, attributes: nil)

                let subfolderNames = ["Photos", "Videos", "Documents", "Contacts"]

                for name in subfolderNames {
                    let subfolderURL = mainFolderURL.appendingPathComponent(name)
                    try fileManager.createDirectory(at: subfolderURL, withIntermediateDirectories: true, attributes: nil)
                }

                print("Folder structure created successfully.")
            } else {
                print("Folder structure already exists.")
            }
        } catch {
            print("Failed to create folder structure: \(error)")
        }
    }
}
