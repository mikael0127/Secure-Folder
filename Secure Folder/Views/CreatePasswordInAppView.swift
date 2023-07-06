//
//  CreatePasswordInApp.swift
//  Secure Folder
//
//  Created by Mikael Denys Wijaya on 24/06/23.
//


import SwiftUI
import Security

struct CreatePasswordInAppView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isPasswordValid: Bool = false
    @State private var showAlert: Bool = false
    @Binding var isPasswordCreated: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                InputView(text: $password,
                          title: "Password",
                          placeholder: "Enter your password",
                          isSecureField: true)
                    .autocapitalization(.none)
                
                ZStack(alignment: .trailing) {
                    InputView(text: $confirmPassword,
                              title: "Confirm Password",
                              placeholder: "Confirm your password",
                              isSecureField: true)
                        .autocapitalization(.none)
                    
                    if !password.isEmpty && !confirmPassword.isEmpty {
                        if password == confirmPassword {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemGreen))
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemRed))
                        }
                    }
                }
                
                Button(action: {
                    createPassword()
                    showAlert = true
                }) {
                    Text("Create Password")
                        .foregroundColor(.white)
                        .padding()
                        .background(isPasswordValid ? Color.green : Color.gray)
                        .cornerRadius(8)
                }
                .disabled(!isPasswordValid)
                .padding()
                
                // NavigationLink to navigate back to HomePageView
                NavigationLink(
                    destination: HomePageView(),
                    isActive: $isPasswordCreated,
                    label: {
                        EmptyView()
                    }
                )
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .onChange(of: password) { _ in
                isPasswordValid = isValidPassword()
            }
            .onChange(of: confirmPassword) { _ in
                isPasswordValid = isValidPassword()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Success"),
                    message: Text("Password successfully created and saved to Keychain."),
                    dismissButton: .default(Text("OK"), action: {
                        presentationMode.wrappedValue.dismiss()
                    })
                )
            }
            .navigationTitle("Create Password")
        }
    }
    
    private func createPassword() {
        guard let passwordData = password.data(using: .utf8) else {
            print("Failed to convert password to Data")
            return
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "UserPassword",
            kSecValueData as String: passwordData
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            print("Password created and saved to Keychain")
            isPasswordCreated = true // Set isPasswordCreated to true after successfully saving the password
        } else {
            print("Failed to save password to Keychain. Status: \(status)")
        }
    }
    
    private func isValidPassword() -> Bool {
        let hasNumeric = password.rangeOfCharacter(from: .decimalDigits) != nil
        let hasAlphabetic = password.rangeOfCharacter(from: .letters) != nil
        
        return password.count >= 6 && password == confirmPassword && (hasNumeric || hasAlphabetic)
    }
}

struct CreatePasswordInAppView_Previews: PreviewProvider {
    @State static private var isPasswordCreated = false
    
    static var previews: some View {
        CreatePasswordInAppView(isPasswordCreated: $isPasswordCreated)
    }
}
