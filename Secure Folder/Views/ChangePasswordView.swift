//
//  ChangePasswordView.swift
//  Secure Folder
//
//  Created by Mikael Denys Widjaja on 21/06/23.
//


import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var passwordsMatch = false
    
    var body: some View {
        VStack {
            InputView(text: $currentPassword,
                      title: "Current Password",
                      placeholder: "Enter your current password",
                      isSecureField: true)
            .autocapitalization(.none)
            .padding(.bottom, 16)
            
            InputView(text: $newPassword,
                      title: "New Password",
                      placeholder: "Enter your new password",
                      isSecureField: true)
            .autocapitalization(.none)
            .padding(.bottom, 16)
            
            ZStack(alignment: .trailing) {
                InputView(text: $confirmPassword,
                          title: "Confirm Password",
                          placeholder: "Confirm your new password",
                          isSecureField: true)
                .autocapitalization(.none)
                .padding(.bottom, 16)
                
                if !newPassword.isEmpty && !confirmPassword.isEmpty {
                    if newPassword == confirmPassword {
                        Image(systemName: "checkmark.circle.fill")
                            .imageScale(.large)
                            .fontWeight(.bold)
                            .foregroundColor(Color(.systemGreen))
                            .onAppear {
                                passwordsMatch = true
                            }
                    } else {
                        Image(systemName: "xmark.circle.fill")
                            .imageScale(.large)
                            .fontWeight(.bold)
                            .foregroundColor(Color(.systemRed))
                            .onAppear {
                                passwordsMatch = false
                            }
                    }
                }
            }
            
            Button(action: {
                authViewModel.changePassword(
                    currentPassword: currentPassword,
                    newPassword: newPassword,
                    confirmPassword: confirmPassword
                ) { result in
                    switch result {
                    case .success:
                        // Handle password change success
                        print("Password changed successfully")
                        showAlert = true
                        alertMessage = "Password Changed!"
                    case .failure(let error):
                        // Handle password change failure
                        print("Password change failed: \(error.localizedDescription)")
                    }
                }
            }) {
                HStack {
                    Text("Change Password")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width - 32, height: 50)
            }
            .background(Color(.systemBlue))
            .cornerRadius(10)
            .padding()
            .opacity(passwordsMatch ? 1.0 : 0.5) // Adjust the opacity based on passwords matching
            .disabled(!passwordsMatch) // Disable the button when passwords don't match
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
        .padding()
        .navigationBarTitle("Change Password")
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView()
            .environmentObject(AuthViewModel())
    }
}
