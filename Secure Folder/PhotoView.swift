//
//  DocumentView.swift
//  Secure Folder
//
//  Created by Bryan Loh on 15/6/23.
//

import Foundation
import SwiftUI
import _PhotosUI_SwiftUI
import UIKit

/*enum PickerType: Identifiable {
    case photo, file, contact
    
    var id: Int {
        hashValue
    }
}*/

enum ImageState {
        case empty
        case loading(Progress)
        case success(Image)
        case failure(Error)
    }

enum TransferError: Error {
        case importFailed
    }

struct PhotoView: View {
    
    @State private var actionSheetVisible = false
    //@State private var pickerType: PickerType?
    
    @State private var selectedItems = [PhotosPickerItem]()
    @State private var selectedImages = [UIImage]()

    var body: some View {
        
        NavigationStack {
            VStack {
                if selectedImages.count > 0 {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(selectedImages, id: \.self) { img in
                                Image(uiImage: img)
                                    .resizable()
                                    .frame(width: 200, height:200)
                            }
                        }
                    }
                } else {
                    Image(systemName: "photo.artframe")
                        .resizable()
                        .frame(width:200, height:200)
                        .foregroundColor(.gray.opacity(0.5))
                        .padding()
                }
                
                PhotosPicker(selection: $selectedItems,maxSelectionCount: 2, matching: .any(of: [.images,.not(.videos)])) {
                    Label("Add New Photo(s)", systemImage: "photo.artframe")
                }
                .onChange(of: selectedItems) { newValue in
                    Task {
                        selectedImages = []
                        for value in newValue {
                            if let imageData = try? await value.loadTransferable(type: Data.self), let image = UIImage(data: imageData) {
                                selectedImages.append(image)
                            }
                        }
                        
                        saveImages() // Call the saveImages function here
                    }
                }
            }
            /*Button("Add New Photo(s)") {
                //self.actionSheetVisible = true
                
            }*/
            /*.confirmationDialog("Select a type", isPresented: self.$actionSheetVisible) {
                Button("Photo") {
                    self.pickerType = .photo
                }
            }*/
            .navigationTitle("Photos")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack{
                        NavigationLink(destination: homePageView(), label: {
                            Text("Back")
                        })
                        
                        Spacer()
                            .frame(width:250)
                        
                        Button("Select") {
                            
                        }
                        
                    }
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
        
        
        
    }
    func saveImages() {
        for (index, image) in selectedImages.enumerated() {
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent("image\(index).jpg")
                do {
                    try imageData.write(to: fileURL)
                    print("Image saved at: \(fileURL)")
                } catch {
                    print("Failed to save image: \(error)")
                }
            }
        }
    }
    
}

struct PhotoView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoView()
        
    }
}

/*import Foundation
import SwiftUI
import UniformTypeIdentifiers
import _PhotosUI_SwiftUI

struct ImageDocument: FileDocument {
    static var readableContentTypes: [UTType] { [UTType.image] }
    
    var image: UIImage
    
    init(image: UIImage) {
        self.image = image
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents, let loadedImage = UIImage(data: data) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        image = loadedImage
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let data = image.jpegData(compressionQuality: 1.0) else {
            throw CocoaError(.fileWriteUnknown)
        }
        return FileWrapper(regularFileWithContents: data)
    }
}

struct PhotoView: View {
    @State private var selectedImages = [UIImage]()
    
    var body: some View {
        VStack {
            if selectedImages.count > 0 {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(selectedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 200, height: 200)
                        }
                    }
                }
            } else {
                Image(systemName: "photo.artframe")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .foregroundColor(.gray.opacity(0.5))
                    .padding()
            }
            
            PhotosPicker<UIImage>(selection: $selectedImages, maxSelectionCount: 2, matching: .any(of: [UTType.image])) {
                Label("Add New Photo(s)", systemImage: "photo.artframe")
            }
        }
        .onChange(of: selectedImages) { newValue in
            saveImages()
        }
    }
    
    func saveImages() {
        for (index, image) in selectedImages.enumerated() {
            let document = ImageDocument(image: image)
            do {
                let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("image\(index).jpg")
                try FileDocumentWriter(document: document, fileURL: fileURL).save()
                print("Image saved at: \(fileURL)")
            } catch {
                print("Failed to save image: \(error)")
            }
        }
    }
}

struct PhotoView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoView()
        
    }
}*/


