//
//  User.swift
//  Secure Folder
//
//  Created by Mikael Denys Widjaja on 10/06/23.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let fullname: String
    let email: String
    let publicKey: Data
    
    var initials: String {
        let formatter =  PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}


