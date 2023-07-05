//
//  testview.swift
//  Secure Folder
//
//  Created by Bryan Loh on 17/6/23.
//


import Foundation
import SwiftUI
import _PhotosUI_SwiftUI

/*enum PickerType: Identifiable {
    case photo, file, contact
    
    var id: Int {
        hashValue
    }
}*/

@MainActor
class TestView: ObservableObject {

    enum ImageState {
        case empty
        case loading(Progress)
        case success(Image)
        case failure(Error)
    }

    enum TransferError: Error {
        case importFailed
    }

    @Published var uiImageToSave: UIImage?

    struct testtest: Transferable {
        let image: Image
        let uiImageX: UIImage

        static var transferRepresentation: some TransferRepresentation {
            DataRepresentation(importedContentType: .image) { data in
            #if canImport(AppKit)
                guard let nsImage = NSImage(data: data) else {
                    throw TransferError.importFailed
                }
                let image = Image(nsImage: nsImage)
                return testtest(image: image)
            #elseif canImport(UIKit)
                guard let uiImage = UIImage(data: data) else {
                    throw TransferError.importFailed
                }
                let image = Image(uiImage: uiImage)
                return testtest(image: image, uiImageX: uiImage)
            #else
                throw TransferError.importFailed
            #endif
            }
        }
    }

    @Published private(set) var imageState: ImageState = .empty

    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            if let imageSelection {
                let progress = loadTransferable(from: imageSelection)

                imageState = .loading(progress)
            } else {
                imageState = .empty
            }
        }
    }
    /*.sheet(item: self.$pickerType, onDismiss: {print("dismiss")}) {item in
        switch item {
        case .photo:
            ImagePicker(image:self.$selectedImage)
        case .file:
            NavigationView {
                Text("file")
            }
        case .contact:
            NavigationView {
                Text("contact")
            }
        }
    }*/

    private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
        return imageSelection.loadTransferable(type: testtest.self) { result in
            DispatchQueue.main.async {
                guard imageSelection == self.imageSelection else {
                    print("Failed to get the selected item.")
                    return
                }
                switch result {
                case .success(let testtest?):
                    self.imageState = .success(testtest.image)
                    self.uiImageToSave = testtest.uiImageX
                case .success(nil):
                    self.imageState = .empty
                case .failure(let error):
                    self.imageState = .failure(error)
                }
            }
        }
    }

}

//save image
class ImageSaver: NSObject {
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) ->Void)?

    func writeToDisk(image: UIImage, imageName: String) {
        let savePath = FileManager.documentsDirectory.appendingPathComponent("\(imageName).jpg") //store data path
        if let jpegData = image.jpegData(compressionQuality: 0.5) { //adjust compression quality
            try? jpegData.write(to: savePath, options: [.atomic, .completeFileProtection])
            print("Image saved")
        }
    }
}

//save image in the documents directory
extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
        
    }
}

