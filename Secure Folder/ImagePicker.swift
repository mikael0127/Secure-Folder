//
//  ImagePicker.swift
//  Secure Folder
//
//  Created by Mikael Denys Wijaya on 16/06/23.
//

import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedPhotos: [UIImage]
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 0 // Set to 0 for unlimited selection
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.selectedPhotos.removeAll()
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                        if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                self?.parent.selectedPhotos.append(image)
                            }
                        }
                    }
                }
            }
            
            parent.selectedPhotos = parent.selectedPhotos.uniqued()
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

extension Array where Element: Equatable {
    func uniqued() -> [Element] {
        var uniqueElements: [Element] = []
        
        for element in self {
            if !uniqueElements.contains(element) {
                uniqueElements.append(element)
            }
        }
        
        return uniqueElements
    }
}
