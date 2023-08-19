//
//  ProfileView.swift
//  Secure Folder
//
//  Created by Mikael Denys Widjaja on 09/06/23.
//


import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var inactivityTimerManager: InactivityTimerManager
    @EnvironmentObject var lockManager: LockManager
    
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
                            NavigationLink(
                                destination: ChangePasswordView().environmentObject(viewModel),
                                label: {
                                    SettingsRowView(imageName: "lock.rotation",
                                                    title: "Change Password",
                                                    tintColor: Color(.systemGray))
                                }
                            )
                            
                            Button {
                                viewModel.signOut(lockManager.isLocked)
                                print("Sign Out success from profile view with islocked = \(lockManager.isLocked)")
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
        .navigationBarTitle("Profile")
        .onTapGesture {
            // Reset the inactivity timer whenever there is user interaction
            inactivityTimerManager.resetTimer()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
            .environmentObject(InactivityTimerManager())
            .environmentObject(LockManager())
    }
}
