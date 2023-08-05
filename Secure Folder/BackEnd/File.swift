//
//  File.Swift
//  Secure Folder
//
//  Created by Bryan Loh on 28/07/2023.
//

import Foundation

/// File name components are used to build the URL for a file's location.
/// - Parameters:
///    - fileName: The file name.
///    - fileExtension: An optional file extension (ex: "txt" for .txt).
///    - directoryName: An optional directory name. If the directory does not exist it will be created.
///    - directoryPath: The directory path were the optional directory name and file will be created (ex: FileManager.SearchPathDirectory.documentsDirectory).
public struct FileURLComponents {
    var fileName: String
    var fileExtension: String?
    var directoryName: String?
    var directoryPath: FileManager.SearchPathDirectory
}

/// When an object conforms to the FileWritable protocol, it is signaling that the object is capable of saving itself to a file.
public protocol FileWritable {
    func write(to fileURLComponents: FileURLComponents) throws -> URL
}

/// When an object conforms to the FileReadable protocol, it is signaling that the object is capable of creating itself from a file's contents.
public protocol FileReadable {
    static func read<T: Decodable>(_ type: T.Type, from fileURLComponents: FileURLComponents) throws -> T
}

/// When an object conforms to the FileDeletable protocol, it is signaling that the object is capable of deleting its file representation.
public protocol FileDeletable {
    static func delete(_ fileURLComponents: FileURLComponents) throws -> Bool
}

/// When an object conforms to Fileable it it is signaling that it will conform to FileWritable, FileReadable, and FileDeletable.
public typealias Fileable = FileWritable & FileReadable & FileDeletable

public enum FileError: Error {
    case unableToCreateDirectory(directory: String, reason: String)
}

/// The File class can be used by an object conforming to FileWriteable and/or FileReadable to handle read/write operations. This class should not be used to instantiate an object as as all functions are static.
public class File: NSObject {
    
    /// A static function that will handle writing data to a file.
    /// - Parameters:
    ///    - data: The data to be written.
    ///    - to: The components that will make up the destination file URL.
    /// - Returns: The URL to the file.
    public static func write(_ data: Data, to fileURLComponents: FileURLComponents) throws -> URL {
        do {
            // Get the file destination url
            let destinationURL = try File.fileURL(using: fileURLComponents)
            
            // Write the data to the file
            try data.write(to: destinationURL)
            return destinationURL
        } catch {
            throw error
        }
    }
    
    /// A static function that will handle reading data from a file.
    /// - Parameters:
    ///    - from: The components that will make up the source file URL.
    /// - Returns: The file data.
    public static func read(from fileURLComponents: FileURLComponents) throws -> Data {
        do {
            // Get the file source url
            let sourceURL = try File.fileURL(using: fileURLComponents)
            
            // Read the data from the file
            return try Data(contentsOf: sourceURL)
        } catch {
            throw error
        }
    }
    
    public static func read(from directoryName: String?, at directoryPath: FileManager.SearchPathDirectory) -> [URL] {
        // Get the destination directory url
        do {
            let dirURL = try File.directoryURL(for: directoryName, at: directoryPath)
            let items = try FileManager.default.contentsOfDirectory(atPath: dirURL.path)
            let urls = items.map {
                URL(fileURLWithPath: $0, relativeTo: dirURL)
            }
            return urls
        } catch {
            print("failed to read from directory: \(error.localizedDescription)")
            return []
        }
    }
    
    /// A static function that will handle deleting a file.
    /// - Parameters:
    ///    - from: The components that will make up the source file URL.
    public static func delete(_ fileURLComponents: FileURLComponents) throws -> Bool {
        do {
            // Get the file source url
            let sourceURL = try File.fileURL(using: fileURLComponents)
            
            // Check for the file's existence
            guard try File.exists(fileURLComponents) else {
                return false
            }
                
            // Delete the file at the URL
            try FileManager.default.removeItem(at: sourceURL)
            return true

        } catch {
            throw error
        }
    }
    
    /// A static function that will look for the existence of a file.
    /// - Parameters:
    ///    - from: The components that will make up the source file URL.
    /// - Returns: Returns `true` is the file exists otherwise returns `false`.
    public static func exists(_ fileURLComponents: FileURLComponents) throws -> Bool {
        do {
            // Get the file source url
            let sourceURL = try File.fileURL(using: fileURLComponents)
            
            // Check for the file's existence
            if FileManager.default.fileExists(atPath: sourceURL.path) {
                return true
            } else {
                return false
            }
        } catch {
            throw error
        }
    }
    
    /// Constructs the file URL from the file components.
    /// - Parameters:
    ///    - using: The file components to be used when constructing the file URL.
    /// - Returns: The file URL.
    private static func fileURL(using fileURLComponents: FileURLComponents) throws -> URL {
        do {
            // Get the destination directory url
            let dirURL = try File.directoryURL(for: fileURLComponents.directoryName, at: fileURLComponents.directoryPath)
            
            // Create the file url
            var fileURL: URL
            if let fileExtension = fileURLComponents.fileExtension {
                // Add the file extension to the url
                fileURL = URL(fileURLWithPath: fileURLComponents.fileName, relativeTo: dirURL).appendingPathExtension(fileExtension)
            } else {
                fileURL = URL(fileURLWithPath: fileURLComponents.fileName, relativeTo: dirURL)
            }
            return fileURL
        } catch {
            throw error
        }
    }
    
    /// Constructs a directory URL from the given directory path and optional name.
    /// - Parameters:
    ///    - for: An optional directory name.
    ///    - at: The base directory path.
    /// - Returns: The directory URL.
    private static func directoryURL(for directoryName: String?, at directoryPath: FileManager.SearchPathDirectory) throws -> URL {
        // Get base directory path url
        var destinationDirectoryURL = FileManager.default.urls(for: directoryPath, in: .userDomainMask)[0]
        
        // Append a new directory name if applicable
        if let directoryName = directoryName {
            destinationDirectoryURL = destinationDirectoryURL.appendingPathComponent(directoryName, isDirectory: true)
        }
        
        // Create the directory
        do {
            try FileManager.default.createDirectory(at: destinationDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            return destinationDirectoryURL
        } catch {
            throw FileError.unableToCreateDirectory(directory: destinationDirectoryURL.absoluteString, reason: error.localizedDescription)
        }
    }
}

//extension File: FileManagerDelegate {
//    public func fileManager(_ fileManager: FileManager, shouldRemoveItemAt URL: URL) -> Bool {
//        // An assumption is being made here that this file should be deleted
//        return true
//    }
//}
