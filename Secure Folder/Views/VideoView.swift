//
//  DocumentView.swift
//  Secure Folder
//
//  Created by Bryan Loh on 15/6/23.
//

import Foundation
import SwiftUI

struct VideoView: View {
    
    var body: some View {
        
        NavigationStack {
            Button("Add New Video(s)") {
                print("New")
            }
                .navigationTitle("Videos")
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
        
    }
}

struct VideoView_Previews: PreviewProvider {
    static var previews: some View {
        VideoView()
    }
}
