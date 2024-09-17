//
//  CredentialRow.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 11.09.2024.
//

import SwiftUI

struct CredentialRow: View {
    @Binding var credential: CredentialWrapper
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @State private var blurTimer: Timer?
    private let passwordBluringAnimation: Animation = .easeInOut(duration: 0.5)
    
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                Text(credential.username)
                Divider()
                Text(settingsViewModel.isPasswordBlured && credential.isPasswordBlured ? "************" : credential.password)
                    .blur(radius: settingsViewModel.isPasswordBlured && credential.isPasswordBlured ? 6 : 0)
                    .onTapGesture {
                        if settingsViewModel.isPasswordBlured {
                            if credential.isPasswordBlured {
                                unblurPassword()
                            } else {
                                blurPassword()
                            }
                        }
                    }
            }
            .contextMenu {
                Button(action: {
                    UIPasteboard.general.string = credential.username
                }, label: {
                    Label("Copy login", systemImage: "doc.on.doc")
                })
                Button(action: {
                    UIPasteboard.general.string = credential.password
                }, label: {
                    Label("Copy password", systemImage: "doc.on.doc")
                })
                Button(action: {
                    onEdit()
                }, label: {
                    Label("Edit", systemImage: "pencil")
                })
                Divider()
                Button(role: .destructive, action: {
                    onDelete()
                }, label: {
                    Label("Delete", systemImage: "trash")
                })
            }
        }
        .listSectionSpacing(.compact)
    }
    
    private func unblurPassword() {
        blurTimer?.invalidate()
        withAnimation(passwordBluringAnimation) {
            credential.isPasswordBlured = false
        }
        
        if settingsViewModel.passwordAutoBlur != .never {
            blurTimer = Timer.scheduledTimer(withTimeInterval: settingsViewModel.passwordAutoBlur.timeInterval, repeats: false) { _ in
                withAnimation(passwordBluringAnimation) {
                    credential.isPasswordBlured = true
                }
            }
        }
    }
    
    private func blurPassword() {
        blurTimer?.invalidate()
        withAnimation(passwordBluringAnimation) {
            credential.isPasswordBlured = true
        }
    }
}

#Preview {
    @StateObject var credentialsViewModel = CredentialsViewModel.preview
    let authenticationViewModel = AuthenticationViewModel()
    let settingsViewModel = SettingsViewModel(credentialsViewModel: credentialsViewModel, authenticationViewModel: authenticationViewModel)
    
    return CredentialRow(credential: $credentialsViewModel.credentialGroups[0].credentials[0], onEdit: {}, onDelete: {})
        .environmentObject(settingsViewModel)
}
