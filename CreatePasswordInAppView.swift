//
//  CreatePasswordInApp.swift
//  Secure Folder
//
//  Created by Mikael Denys Wijaya on 24/06/23.
//

import SwiftUI

struct CreatePasswordInAppView: View {
    @State private var password = ""
    @State private var isPasswordValid = false
    
    var body: some View {
        VStack {
            SecureField("Enter Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onChange(of: password) { newValue in
                    isPasswordValid = isValidPassword(newValue)
                }
            
            Button(action: createPassword) {
                Text("Create Password")
                    .foregroundColor(.white)
                    .padding()
                    .background(isPasswordValid ? Color.green : Color.gray)
                    .cornerRadius(8)
            }
            .disabled(!isPasswordValid)
            .padding()
        }
        .navigationTitle("Create Password")
    }
    
    private func createPassword() {
        // Handle password creation logic here
        // For example, save the password to UserDefaults or send it to a server
        // You can access the created password using the 'password' property
        UserDefaults.standard.set(password, forKey: "UserPassword")
        print("Password created: \(password)")
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        return password.count == 6
    }
}

struct CreatePasswordInAppView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePasswordInAppView()
    }
}

