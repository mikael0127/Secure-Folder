//
//  DocumentView.swift
//  Secure Folder
//
//  Created by Bryan Loh on 15/6/23.
//

import Foundation
import SwiftUI

struct DocumentView: View {
    
    var body: some View {
        
        NavigationStack {
            Button("Add New Document(s)") {
                print("New")
            }
                .navigationTitle("Documents")
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
        
    }
}

struct DocumentView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentView()
    }
}
