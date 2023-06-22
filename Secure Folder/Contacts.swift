//
//  Contacts.swift
//  Secure Folder
//
//  Created by Mikael Denys Wijaya on 22/06/23.
//

import Contacts
import Foundation
import SwiftUI
import ContactsUI

private var contactsImported = false

struct ContactPickerView: UIViewControllerRepresentable {
    var onContactsSelected: ([CNContact]) -> Void

    func makeUIViewController(context: UIViewControllerRepresentableContext<ContactPickerView>) -> UIViewController {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = context.coordinator
        return contactPicker
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<ContactPickerView>) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onContactsSelected: onContactsSelected)
    }

    final class Coordinator: NSObject, CNContactPickerDelegate {
        var onContactsSelected: ([CNContact]) -> Void

        init(onContactsSelected: @escaping ([CNContact]) -> Void) {
            self.onContactsSelected = onContactsSelected
        }

        func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
            onContactsSelected(contacts)
        }
    }
}


func importContacts() {
    DispatchQueue.global().async {
        let store = CNContactStore()

        store.requestAccess(for: .contacts) { (granted, error) in
            if granted {
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])

                do {
                    var contacts = [ContactModel]()

                    try store.enumerateContacts(with: request) { (contact, stopPointer) in
                        let givenName = contact.givenName
                        let familyName = contact.familyName
                        let phoneNumbers = contact.phoneNumbers.map { $0.value.stringValue }

                        let newContact = ContactModel(givenName: givenName, familyName: familyName, phoneNumbers: phoneNumbers)
                        contacts.append(newContact)
                    }
                    // Save the contacts to a folder or perform any other desired actions
                    saveContacts(contacts)
                    DispatchQueue.main.async {
                        // Set the contactsImported state variable to trigger the navigation
                        contactsImported = true
                    }
                } catch {
                    print("Failed to enumerate contacts: \(error.localizedDescription)")
                }
            } else {
                print("Access to contacts denied.")
            }
        }
    }
}

func saveContacts(_ contacts: [ContactModel]) {
    // Perform the necessary operations to save the contacts into a folder
    // This could involve writing the contact information to a file or storing it in a database
    // Here, you can use FileManager to create a file and save the contacts
    
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    let filePath = documentsDirectory?.appendingPathComponent("contacts.txt")
    
    var contactsText = ""
    
    for contact in contacts {
        let contactText = "\(contact.givenName) \(contact.familyName): \(contact.phoneNumbers.joined(separator: ", "))"
        contactsText += contactText + "\n"
    }
    
    do {
        try contactsText.write(to: filePath!, atomically: true, encoding: .utf8)
        print("Contacts saved to file: \(filePath!.path)")
    } catch {
        print("Failed to save contacts: \(error.localizedDescription)")
    }
}

