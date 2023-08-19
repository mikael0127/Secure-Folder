//
//  ResetPasswordView.swift
//  Secure Folder
//
//  Created by Mikael Denys Widjaja on 18/06/23.
//

import SwiftUI

struct ResetPasswordView: View {
    @State private var email = ""
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            VStack {
                // Image
                Image(systemName: "folder.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Secure Folder")
                    .font(.system(size: 26))
                    .foregroundColor(.black.opacity(0.8))
                    .padding(.bottom, 32)
            }
            
            
            InputView(text: $email,
                      title: "Email Address",
                      placeholder: "Enter the email associated with your account")
            .padding()
            .autocapitalization(.none)
            
            Button {
                viewModel.sendResetPasswordLink(toEmail: email)
                dismiss()
            } label: {
                HStack {
                    Text("SEND RESET LINK")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width - 32, height: 50)
            }
            .background(Color(.systemBlue))
            .cornerRadius(10)
            .padding()
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "arrow.left")
                    
                    Text("Back to Login")
                        .fontWeight(.semibold)
                }
                .font(.system(size: 15))
            }
        }
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
            .environmentObject(AuthViewModel())
    }
}

