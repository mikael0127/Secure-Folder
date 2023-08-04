//
//  DocumentView.swift
//  Secure Folder
//
//  Created by Bryan Loh on 15/6/23.
//

// Mikael Attempt 1
//import Foundation
//import SwiftUI
//import _PhotosUI_SwiftUI
//import UIKit
//
//enum ImageState {
//    case empty
//    case loading(Progress)
//    case success(Image)
//    case failure(Error)
//}
//
//enum TransferError: Error {
//    case importFailed
//}
//
//struct PhotoView: View {
//
//    @State private var selectedItems = [PhotosPickerItem]()
//    @State private var selectedImages = [UIImage]()
//
//    var body: some View {
//
//        NavigationStack {
//            VStack {
//                if selectedImages.count > 0 {
//                    ScrollView(.horizontal) {
//                        HStack {
//                            ForEach(selectedImages, id: \.self) { img in
//                                Image(uiImage: img)
//                                    .resizable()
//                                    .frame(width: 200, height: 200)
//                            }
//                        }
//                    }
//                } else {
//                    Image(systemName: "photo.artframe")
//                        .resizable()
//                        .frame(width: 200, height: 200)
//                        .foregroundColor(.gray.opacity(0.5))
//                        .padding()
//                }
//
//                PhotosPicker(selection: $selectedItems, matching: .any(of: [.images, .not(.videos)])) {
//                    Label("Add New Photo(s)", systemImage: "photo.artframe")
//                }
//                .onChange(of: selectedItems) { newValue in
//                    Task {
//                        selectedImages = []
//                        for value in newValue {
//                            do {
//                                if let imageData = try await value.loadTransferable(type: Data.self), let image = UIImage(data: imageData) {
//                                    selectedImages.append(image)
//                                }
//                            } catch {
//                                print("Failed to load image: \(error)")
//                            }
//                        }
//
//                        await saveImages() // Call the saveImages function here
//                    }
//                }
//            }
//            .navigationTitle("Photos")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    HStack {
//                        NavigationLink(destination: HomePageView()) {
//                            Text("Back")
//                        }
//
//                        Spacer()
//                            .frame(width: 250)
//
//                        Button("Select") {
//                            // Perform the desired action upon selecting images
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    func saveImages() async {
//        let fileManager = FileManager.default
//        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let photosDirectory = documentsDirectory.appendingPathComponent("MainFolder/Photos")
//
//        do {
//            try fileManager.createDirectory(at: photosDirectory, withIntermediateDirectories: true, attributes: nil)
//        } catch {
//            print("Failed to create photos directory: \(error)")
//            // Display an alert or update the UI to inform the user of the error
//            return
//        }
//
//        for (index, image) in selectedImages.enumerated() {
//            if let imageData = image.jpegData(compressionQuality: 1.0) {
//                let fileURL = photosDirectory.appendingPathComponent("image\(index).jpg")
//                do {
//                    try await imageData.write(to: fileURL)
//                    print("Image saved at: \(fileURL)")
//                } catch {
//                    print("Failed to save image: \(error)")
//                    // Display an alert or update the UI to inform the user of the error
//                }
//            }
//        }
//    }
//}
//
//struct PhotoView_Previews: PreviewProvider {
//    static var previews: some View {
//        PhotoView()
//    }
//}

// Bryan Attempt 22398471982374
import Foundation
import SwiftUI
import _PhotosUI_SwiftUI
import UIKit

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
    @State private var selectedItems = [PhotosPickerItem]()
    @State private var selectedImages = [UIImage]()
    @State private var imageFilenames: [String] = [] // Store image filenames
    @State private var isSelecting: Bool = false
    @State private var selected: [UIImage] = []
    
    init() {
        UINavigationBar.appearance().backgroundColor = .clear
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
    }
    
    var body: some View {
        
//        NavigationStack {
            VStack {
                if selectedImages.count > 0 {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 4) { // Adjust spacing here
                            ForEach(selectedImages, id: \.self) { img in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 200)
                                        .cornerRadius(10)
                                    
                                    if isSelecting {
                                        ZStack {
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 24, height: 24)
                                            
                                            Image(systemName: "checkmark.circle.fill")
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                                .foregroundColor(.green)
                                        }
                                        .opacity(selected.contains(img) ? 1 : 0)
                                    }
                                }
                                .onTapGesture {
                                    guard isSelecting else { return }
                                    if selected.contains(img) {
                                        selected.removeAll(where: { $0 == img })
                                    } else {
                                        selected.append(img)
                                    }
                                }
                                
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                } else {
                    Image(systemName: "photo.artframe")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .foregroundColor(.gray.opacity(0.5))
                        .padding()
                }
                
                PhotosPicker(selection: $selectedItems, matching: .any(of: [.images, .not(.videos)])) {
                    Label("Add New Photo(s)", systemImage: "photo.artframe")
                }
                .padding()
                .onChange(of: selectedItems) { newValue in
                    Task {
                        selectedImages = []
                        for value in newValue {
                            do {
                                if let imageData = try await value.loadTransferable(type: Data.self), let image = UIImage(data: imageData) {
                                    selectedImages.append(image)
                                }
                            } catch {
                                print("Failed to load image: \(error)")
                            }
                        }
                        
                        await saveImages() // Call the saveImages function here
                    }
                }
            }
            .navigationTitle("Photos")
            .toolbar {
                
                if isSelecting {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            FileSharing.shared.message(selected)
                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                
                                Text("Share")
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Perform the desired action upon tapping the "Select" button
                        if isSelecting { selected.removeAll() }
                        isSelecting.toggle()
                    }) {
                        Text(isSelecting ? "Cancel" : "Select")
                    }
                    
                }
                
            }
//        }
        .onAppear {
            // Retrieve image filenames from User Defaults when the view appears
            imageFilenames = loadImageFilenames()
            selectedImages = loadImages()
            
            // Check if the stored image filenames are still valid
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let photosDirectory = documentsDirectory.appendingPathComponent("MainFolder/Photos")
            
            imageFilenames = imageFilenames.filter { filename in
                let fileURL = photosDirectory.appendingPathComponent(filename)
                return fileManager.fileExists(atPath: fileURL.path)
            }
            
            // Save the updated image filenames
            saveImageFilenames()
        }
    }
    
    func saveImages() async {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let photosDirectory = documentsDirectory.appendingPathComponent("MainFolder/Photos")
        
        do {
            try fileManager.createDirectory(at: photosDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create photos directory: \(error)")
            // Display an alert or update the UI to inform the user of the error
            return
        }
        
        for (index, image) in selectedImages.enumerated() {
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                let filename = "image\(index).jpg"
                let fileURL = photosDirectory.appendingPathComponent(filename)
                do {
                    try await imageData.write(to: fileURL)
                    print("Image saved at: \(fileURL)")
                    // Store the filename
                    imageFilenames.append(filename)
                    saveImageFilenames() // Save image filenames to User Defaults
                } catch {
                    print("Failed to save image: \(error)")
                    // Display an alert or update the UI to inform the user of the error
                }
            }
        }
    }
    
    func loadImages() -> [UIImage] {
        var loadedImages: [UIImage] = []
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let photosDirectory = documentsDirectory.appendingPathComponent("MainFolder/Photos")
        
        for filename in imageFilenames {
            let fileURL = photosDirectory.appendingPathComponent(filename)
            if let imageData = try? Data(contentsOf: fileURL), let image = UIImage(data: imageData) {
                loadedImages.append(image)
            }
        }
        
        return loadedImages
    }
    
    func loadImageFilenames() -> [String] {
        if let savedFilenames = UserDefaults.standard.array(forKey: "imageFilenames") as? [String] {
            return savedFilenames
        } else {
            return []
        }
    }
    
    func saveImageFilenames() {
        UserDefaults.standard.set(imageFilenames, forKey: "imageFilenames")
    }
}

struct PhotoView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoView()
    }
}



// Bryan Attempt
//import Foundation
//import SwiftUI
//import _PhotosUI_SwiftUI
//import UIKit
//
///*enum PickerType: Identifiable {
//    case photo, file, contact
//
//    var id: Int {
//        hashValue
//    }
//}*/
//
//enum ImageState {
//        case empty
//        case loading(Progress)
//        case success(Image)
//        case failure(Error)
//    }
//
//enum TransferError: Error {
//        case importFailed
//    }
//
//struct PhotoView: View {
//
//    @State private var actionSheetVisible = false
//    //@State private var pickerType: PickerType?
//
//    @State private var selectedItems = [PhotosPickerItem]()
//    @State private var selectedImages = [UIImage]()
//
//    var body: some View {
//
//        NavigationStack {
//            VStack {
//                if selectedImages.count > 0 {
//                    ScrollView(.horizontal) {
//                        HStack {
//                            ForEach(selectedImages, id: \.self) { img in
//                                Image(uiImage: img)
//                                    .resizable()
//                                    .frame(width: 200, height:200)
//                            }
//                        }
//                    }
//                } else {
//                    Image(systemName: "photo.artframe")
//                        .resizable()
//                        .frame(width:200, height:200)
//                        .foregroundColor(.gray.opacity(0.5))
//                        .padding()
//                }
//
//                PhotosPicker(selection: $selectedItems,maxSelectionCount: 10, matching: .any(of: [.images,.not(.videos)])) {
//                    Label("Add New Photo(s)", systemImage: "photo.artframe")
//                }
//                .onChange(of: selectedItems) { newValue in
//                    Task {
//                        selectedImages = []
//                        for value in newValue {
//                            if let imageData = try? await value.loadTransferable(type: Data.self), let image = UIImage(data: imageData) {
//                                selectedImages.append(image)
//                            }
//                        }
//
//                        saveImages() // Call the saveImages function here
//                    }
//                }
//            }
//            /*Button("Add New Photo(s)") {
//                //self.actionSheetVisible = true
//
//            }*/
//            /*.confirmationDialog("Select a type", isPresented: self.$actionSheetVisible) {
//                Button("Photo") {
//                    self.pickerType = .photo
//                }
//            }*/
//            .navigationTitle("Photos")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    HStack{
//                        NavigationLink(destination: HomePageView(), label: {
//                            Text("Back")
//                        })
//
//                        Spacer()
//                            .frame(width:250)
//
//                        Button("Select") {
//
//                        }
//
//                    }
//                }
//            }
//        }
//        /*.sheet(item: self.$pickerType, onDismiss: {print("dismiss")}) {item in
//            switch item {
//            case .photo:
//                ImagePicker(image:self.$selectedImage)
//            case .file:
//                NavigationView {
//                    Text("file")
//                }
//            case .contact:
//                NavigationView {
//                    Text("contact")
//                }
//            }
//        }*/
//
//
//
//    }
//    func saveImages() {
//        for (index, image) in selectedImages.enumerated() {
//            if let imageData = image.jpegData(compressionQuality: 1.0) {
//                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//                let fileURL = documentsURL.appendingPathComponent("image\(index).jpg")
//                do {
//                    try imageData.write(to: fileURL)
//                    print("Image saved at: \(fileURL)")
//                } catch {
//                    print("Failed to save image: \(error)")
//                }
//            }
//        }
//    }
//
//}
//
//struct PhotoView_Previews: PreviewProvider {
//    static var previews: some View {
//        PhotoView()
//
//    }
//}

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


