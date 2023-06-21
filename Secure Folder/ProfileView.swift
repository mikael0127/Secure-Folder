//
//  ProfileView.swift
//  SwiftAuthTutorial
//
//  Created by Mikael Denys Wijaya on 09/06/23.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            VStack {
                if let user = viewModel.currentUser {
                    List {
                        Section {
                            HStack {
                                Text(user.initials)
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(width: 72, height: 72)
                                    .background(Color(.systemGray3))
                                .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(user.fullname)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .padding(.top, 4)
                                    
                                    Text(user.email)
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        Section("General") {
                            HStack {
                                SettingsRowView(imageName: "gear",
                                                title: "Version",
                                                tintColor: Color(.systemGray))
                                
                                Spacer()
                                
                                Text("1.0.0")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Section("Account") {
                            Button {
                                viewModel.signOut()
                            } label: {
                                SettingsRowView(imageName: "arrow.left.circle.fill",
                                                title: "Sign Out",
                                                tintColor: Color(.systemRed))
                            }
                            
                            Button {
                                Task {
                                    try await viewModel.deleteAccount()
                                }
                            } label: {
                                SettingsRowView(imageName: "xmark.circle.fill",
                                                title: "Delete Account",
                                                tintColor: Color(.systemRed))
                            }
                        }
                    }
                }
            }
            
            if viewModel.isLoading {
                CustomProgressView()
            }
        }
        .navigationBarTitle(Text("Profile").fontWeight(.semibold))
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}
