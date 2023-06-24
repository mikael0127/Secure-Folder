//
//  DocumentView.swift
//  Secure Folder
//
//  Created by Bryan Loh on 15/6/23.
//

import Foundation
import SwiftUI

enum PickerType: Identifiable {
    case photo, file, contact
    
    var id: Int {
        hashValue
    }
}

struct PhotoView: View {
    
    @State private var actionSheetVisible = false
    @State private var pickerType: PickerType?
    
    @State private var selectedImage: UIImage?
    
    
    var body: some View {
        
        NavigationStack {
            
            Button("Add New Photo(s)") {
                self.actionSheetVisible = true
                
            }
            .confirmationDialog("Select a type", isPresented: self.$actionSheetVisible) {
                Button("Photo") {
                    self.pickerType = .photo
                }
            }
                .navigationTitle("Photos")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack{
                            NavigationLink(destination: HomePageView(), label: {
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
        .sheet(item: self.$pickerType, onDismiss: {print("dismiss")}) {item in
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
        }
        
    }
}

struct PhotoView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoView()
    }
}
