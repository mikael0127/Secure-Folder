//
//  PhotosView.swift
//  Secure Folder
//
//  Created by Mikael Denys Wijaya on 16/06/23.
//

import SwiftUI
import PhotosUI

struct PhotosView: View {
    // To store the selected photos
    @State private var selectedPhotos: [UIImage] = []

    var body: some View {
        VStack {
            if selectedPhotos.isEmpty {
                Text("No photos selected")
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                        ForEach(selectedPhotos, id: \.self) { photo in
                            Image(uiImage: photo)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 80)
                        }
                    }
                }
            }
        }
        .navigationBarTitle(Text("Photo Gallery").fontWeight(.semibold))
    }
}

//import SwiftUI
//import PhotosUI
//
//class SelectedPhotos: ObservableObject {
//    @Published var photos: [UIImage] = []
//
//    func removeDuplicates() {
//        photos = Array(Set(photos))
//    }
//}
//
//struct PhotosView: View {
//    // To store the selected photos
//    @StateObject private var selectedPhotos = SelectedPhotos()
//
//    // Boolean to track whether the photo picker is active
//    @State private var isShowingPicker = false
//
//    var body: some View {
//        VStack {
//            if selectedPhotos.photos.isEmpty {
//                Text("No photos selected")
//            } else {
//                ScrollView {
//                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
//                        ForEach(selectedPhotos.photos, id: \.self) { photo in
//                            Image(uiImage: photo)
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(height: 80)
//                        }
//                    }
//                }
//            }
//        }
//        .navigationBarTitle(Text("Photo Gallery").fontWeight(.semibold))
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: {
//                    isShowingPicker = true
//                }) {
//                    Image(systemName: "plus")
//                }
//            }
//        }
//        .sheet(isPresented: $isShowingPicker) {
//            ImagePicker(selectedPhotos: $selectedPhotos.photos)
//                .onDisappear {
//                    // Remove duplicates from selected photos (if any)
//                    selectedPhotos.removeDuplicates()
//                }
//        }
//    }
//}

struct PhotosView_Previews: PreviewProvider {
    static var previews: some View {
        PhotosView()
    }
}


