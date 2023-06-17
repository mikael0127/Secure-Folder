//
//  DocumentView.swift
//  Secure Folder
//
//  Created by Bryan Loh on 15/6/23.
//

import Foundation
import SwiftUI

struct PhotoView: View {
    
    var body: some View {
        
        NavigationStack {
            Button("Add New Photo(s)") {
                print("New")
            }
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
        
    }
}

struct PhotoView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoView()
    }
}
