//
//  DocumentView.swift
//  Secure Folder
//
//  Created by Bryan Loh on 15/6/23.
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
}

struct PhotoView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoView()
        
    }
}
