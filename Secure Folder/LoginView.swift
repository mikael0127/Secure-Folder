//
//  LoginView.swift
//  SwiftAuthTutorial
//
//  Created by Mikael Denys Wijaya on 09/06/23.
//

import SwiftUI

struct LoginView: View {
    @State var email = ""
    @State var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
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
//                    Image("Audi_Rs7")
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: 100, height: 120)
//                        .padding(.vertical, 32)
                    
                    // Form fields
                    VStack(spacing: 24) {
                        InputView(text: $email,
                                  title: "Email Address",
                                  placeholder: "name@example.com")
                        .autocapitalization(.none)
                        
                        InputView(text: $password,
                                  title: "Password",
                                  placeholder: "Enter your password",
                                  isSecureField: true)
                        .autocapitalization(.none)
                        
                        NavigationLink {
                            ResetPasswordView()
                                .navigationBarHidden(true)
                        } label: {
                            Text("Forgot Password?")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.blue)
                            
                        }
                        .padding(.bottom)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    // Sign in button
                    Button {
                        Task {
                            try await viewModel.signIn(withEmail: email, password: password)
                        }
                    } label: {
                        HStack {
                            Text("SIGN IN")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                    }
                    .background(Color(.systemBlue))
                    .disabled(!formIsValid)
                    .opacity(formIsValid ? 1.0 : 0.5)
                    .cornerRadius(10)
                    .padding(.top,24)
                
                    Spacer()
                    
                    // Sign up button
                    NavigationLink {
                        RegistrationView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        HStack(spacing: 3) {
                            Text("Don't have an account?")
                                .foregroundColor(Color(.systemGray))
                            Text("Sign up").fontWeight(.bold)
                        }
                        .font(.system(size: 15))
                    }
                }
                .alert(isPresented: $viewModel.showAlert) {
                    Alert(title: Text("Error"),
                          message: Text(viewModel.authError?.description ?? ""))
                }
                
                if viewModel.isLoading {
                    CustomProgressView()
                }
            }
        }
    }
}

// MARK: - AuthenticationFormProtocol

extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
