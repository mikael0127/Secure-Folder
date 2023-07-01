//
//  ContactListView.swift
//  Secure Folder
//
//  Created by Mikael Denys Wijaya on 22/06/23.
//
//


import SwiftUI
import Contacts
import ContactsUI

class ContactPickerDelegate: NSObject, ObservableObject, CNContactPickerDelegate {
    var selectedContacts: [CNContact] = []
    @Published var importedContacts: [ContactModel] = []

    override init() {
        super.init()
        loadContacts()
    }

    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        selectedContacts = contacts
        importSelectedContacts()
    }

    func importSelectedContacts() {
        var importedContacts = self.importedContacts

        for contact in selectedContacts {
            let givenName = contact.givenName
            let familyName = contact.familyName
            let phoneNumbers = contact.phoneNumbers.map { $0.value.stringValue }

            let newContact = ContactModel(givenName: givenName, familyName: familyName, phoneNumbers: phoneNumbers)
            importedContacts.append(newContact)
        }

        self.importedContacts = importedContacts
        saveContacts(importedContacts)
    }

    func loadContacts() {
        // Access the documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

        // Access the "MainFolder"
        let mainFolderURL = documentsDirectory?.appendingPathComponent("MainFolder")
        
        // Access the subfolder "contacts" inside "MainFolder"
        let contactsFolderURL = mainFolderURL?.appendingPathComponent("Contacts")
        
        // Append the file name to the subfolder URL
        let filePath = contactsFolderURL?.appendingPathComponent("contacts.txt")
        
        do {
            let contactsText = try String(contentsOf: filePath!, encoding: .utf8)
            let contactLines = contactsText.components(separatedBy: .newlines)

            var importedContacts: [ContactModel] = []

            for line in contactLines {
                let components = line.components(separatedBy: ":")
                if components.count == 2 {
                    let name = components[0]
                    let numbers = components[1].components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                    let nameComponents = name.components(separatedBy: " ")
                    let givenName = nameComponents.first ?? ""
                    let familyName = nameComponents.last ?? ""

                    let newContact = ContactModel(givenName: givenName, familyName: familyName, phoneNumbers: numbers)
                    importedContacts.append(newContact)
                }
            }

            self.importedContacts = importedContacts
        } catch {
            print("Failed to load contacts: \(error.localizedDescription)")
        }
    }
    
    func deleteContact(at indexSet: IndexSet) {
        importedContacts.remove(atOffsets: indexSet)
        saveContacts(importedContacts)
    }
}

struct ContactListView: View {
    @StateObject private var pickerDelegate = ContactPickerDelegate()

    var body: some View {
        VStack {
            List {
                ForEach(pickerDelegate.importedContacts) { contact in
                    VStack(alignment: .leading) {
                        Text("\(contact.givenName) \(contact.familyName)")
                        ForEach(contact.phoneNumbers, id: \.self) { phoneNumber in
                            Text(phoneNumber)
                        }
                    }
                }
                .onDelete(perform: pickerDelegate.deleteContact) // Enable deletion
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
        .navigationBarItems(trailing: EditButton()) // Enable edit mode
        .onAppear {
            pickerDelegate.loadContacts()
        }
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


