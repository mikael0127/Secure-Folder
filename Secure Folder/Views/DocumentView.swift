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

struct DocumentView: View {
    
    @State private var actionSheetVisible = false
    @State private var pickerType: PickerType?
    @State private var selectedType: PickerType?
    
    @State private var selectedDocument: Data?
    @State private var selectedDocumentText: String?
    
    var body: some View {
        
        NavigationStack {
            Button("Add New Document(s)") {
                self.actionSheetVisible = true
            }
            .confirmationDialog("Select a type", isPresented: self.$actionSheetVisible) {
                Button("File") {
                    self.pickerType = .file
                }
            }
                .navigationTitle("Documents")
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
        .sheet(item: self.$pickerType,onDismiss: {print("dismiss")}) {item in
            switch item {
            case .photo:
                NavigationView {
                    Text("photo")
                }
            case .file:
                FilePicker(file:self.$selectedDocument,
                           fileName:self.$selectedDocumentText)
            case .contact:
                NavigationView {
                    Text("contact")
                }
            }
        }
        
    }
}

struct DocumentView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentView()
    }
}
