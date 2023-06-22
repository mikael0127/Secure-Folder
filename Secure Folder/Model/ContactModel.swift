//
//  Contacts.swift
//  Secure Folder
//
//  Created by Mikael Denys Wijaya on 22/06/23.
//

import Foundation

struct ContactModel: Identifiable, Codable {
    let id = UUID()
    let givenName: String
    let familyName: String
    let phoneNumbers: [String]
}

