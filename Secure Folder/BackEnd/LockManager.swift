//
//  LockManager.swift
//  Secure Folder
//
//  Created by Mikael Denys Widjaja on 12/8/23.
//

import SwiftUI

class LockManager: ObservableObject {
    // Use @AppStorage to persist the isLocked value
    @AppStorage("isLocked") var isLocked = true
}
