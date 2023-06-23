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

struct VideoView: View {
    
    @State private var actionSheetVisible = false
    //@State private var pickerType: PickerType?
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: Image?

    var body: some View {
        
        NavigationStack {
            VStack {
                if let selectedImage {
                    selectedImage
                        .resizable()
                        .frame(width:200, height:200)
                        .padding()
                } else {
                    Image(systemName: "photo.artframe")
                        .resizable()
                        .frame(width:200, height:200)
                        .foregroundColor(.gray.opacity(0.5))
                        .padding()
                }
                
                PhotosPicker(selection: $selectedItem, matching: .videos) {
                    Label("Add New Video(s)", systemImage: "photo.artframe")
                }
                /*.onChange(of: selectedItem) { newValue in
                    Task {
                        if let imageData = try? await
                            newValue?
                            .loadTransferable(type: Data.self), let image =
                            UIImage(data:imageData) {
                            selectedImage = Image(uiImage:image)
                        }
                    }
                }*/
            }
            /*Button("Add New Photo(s)") {
                //self.actionSheetVisible = true
                
            }*/
            /*.confirmationDialog("Select a type", isPresented: self.$actionSheetVisible) {
                Button("Photo") {
                    self.pickerType = .photo
                }
            }*/
            .navigationTitle("Videos")
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

struct VideoView_Previews: PreviewProvider {
    static var previews: some View {
        VideoView()
        
    }
}
