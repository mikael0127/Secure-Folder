//
//  ContactListView.swift
//  Secure Folder
//
//  Created by Mikael Denys Wijaya on 22/06/23.
//

import SwiftUI
import Contacts
import ContactsUI


class ContactPickerDelegate: NSObject, ObservableObject, CNContactPickerDelegate {
    var selectedContacts: [CNContact] = []
    @Published var importedContacts: [ContactModel] = []

    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        selectedContacts = contacts
        importSelectedContacts()
    }
    
    func importSelectedContacts() {
        var importedContacts = self.importedContacts  // Get the existing imported contacts

        for contact in selectedContacts {
            let givenName = contact.givenName
            let familyName = contact.familyName
            let phoneNumbers = contact.phoneNumbers.map { $0.value.stringValue }

            let newContact = ContactModel(givenName: givenName, familyName: familyName, phoneNumbers: phoneNumbers)
            importedContacts.append(newContact)  // Append newly imported contacts to the existing array
        }

        // Save the imported contacts
        saveContacts(importedContacts)

        // Update the importedContacts array with all imported contacts
        self.importedContacts = importedContacts
    }
}

struct ContactListView: View {
    @StateObject private var pickerDelegate = ContactPickerDelegate()

    var body: some View {
        VStack {
            
            List(pickerDelegate.importedContacts, id: \.id) { contact in
                VStack(alignment: .leading) {
                    Text("\(contact.givenName) \(contact.familyName)")
                    ForEach(contact.phoneNumbers, id: \.self) { phoneNumber in
                        Text(phoneNumber)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            
            Button(action: {
                showContactPicker()
            }) {
                Text("Import Contacts")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.blue)
                    .cornerRadius(10)
                    
            }
            .padding(.vertical, 32)
        }
        .navigationTitle(Text("Contacts List").font(.title))
        
    }

    private func showContactPicker() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = pickerDelegate
        UIApplication.shared.windows.first?.rootViewController?.present(contactPicker, animated: true, completion: nil)
    }
}

struct ContactListView_Previews: PreviewProvider {
    static var previews: some View {
        ContactListView()
    }
}

