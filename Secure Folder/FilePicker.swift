//
//  FilePicker.swift
//  Secure Folder
//
//  Created by Bryan Loh on 22/6/23.
//

import Foundation
import SwiftUI
import UIKit

struct FilePicker: UIViewControllerRepresentable {
    
    @Binding var file: Data?
    @Binding var fileName: String?
    
    func makeCoordinator() -> FilePicker.Coordinator {
        return FilePicker.Coordinator(parent1: self)
    }
    func makeUIViewController(context: UIViewControllerRepresentableContext<FilePicker>) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .open)
        picker.allowsMultipleSelection = false
        picker.shouldShowFileExtensions = true
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: FilePicker.UIViewControllerType, context: UIViewControllerRepresentableContext<FilePicker>) {
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: FilePicker
        
        init(parent1: FilePicker) {
            self.parent = parent1
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            print("[FilePicker] didPickDocumentsAt")
            guard controller.documentPickerMode == .open, let url = urls.first, url.startAccessingSecurityScopedResource()
                else { return }
            DispatchQueue.main.async {
                url.stopAccessingSecurityScopedResource()
                print("[FilePicker] stopAccessingSecurityScopedResource done")
            }
            do {
                let document = try Data(contentsOf: url.absoluteURL)
                self.parent.file = document
                self.parent.fileName = url .lastPathComponent
                print("[FilePicker] File Selected: " + url.path)
            }
            catch {
                print("[FilePicker] Error selecting file: " + error.localizedDescription)
                
            }
        }
        
    }
    
}
