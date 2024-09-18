//
//  SettingsView.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 26.08.2024.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @State private var isFaceIDEnabled: Bool = false
    @State private var showAlert: Bool = false
    
    var body: some View {
        Form {
            Section {
                Toggle(isOn: $isFaceIDEnabled, label: {
                    Text("Enable Face ID authentication")
                })
                .onAppear() {
                    isFaceIDEnabled = settingsViewModel.isFaceIDEnabled
                }
                .onChange(of: isFaceIDEnabled) {
                    if isFaceIDEnabled != settingsViewModel.isFaceIDEnabled {
                        if isFaceIDEnabled {
                            do {
                                try settingsViewModel.enableFaceID()
                            } catch {
                                showAlert = true
                            }
                        } else {
                            try? settingsViewModel.disableFaceID()
                        }
                    }
                }
                
                Picker("Theme", selection: $settingsViewModel.appTheme) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
                .pickerStyle(.navigationLink)
            }
            
            Section {
                Toggle(isOn: $settingsViewModel.isPasswordBlured, label: {
                    Text("Password Blur")
                })
                
                Picker("Password Auto-Blur", selection: $settingsViewModel.passwordAutoBlur) {
                    ForEach(PasswordAutoBlur.allCases) { interval in
                        Text(interval.rawValue).tag(interval)
                    }
                }
                .pickerStyle(.navigationLink)
                .disabled(!settingsViewModel.isPasswordBlured)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Cannot Enable Face ID Authentication"),
                message: Text("Restart the application and try again."),
                dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    let credentialsViewModel = CredentialsViewModel()
    let authenticationViewModel = AuthenticationViewModel()
    let settingsViewModel = SettingsViewModel(credentialsViewModel: credentialsViewModel, authenticationViewModel: authenticationViewModel)
    
    return SettingsView().environmentObject(settingsViewModel)
}
