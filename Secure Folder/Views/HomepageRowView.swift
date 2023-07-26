//
//  HomepageRowView.swift
//  Secure Folder
//
//  Created by Mikael Denys Widjaja on 21/7/23.
//

import SwiftUI

struct HomepageRowView: View {
    let imageName: String
    let title: String
    let tintColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: imageName)
                .imageScale(.small)
                .font(.title)
                .foregroundColor(tintColor)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.black)
            
        }
    }
}

struct HomepageRowView_Previews: PreviewProvider {
    static var previews: some View {
        HomepageRowView(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
    }
}
