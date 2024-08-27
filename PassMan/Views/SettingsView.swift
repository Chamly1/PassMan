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
            Section(content: {
                Toggle(isOn: $isFaceIDEnabled, label: {
                    Text("Enable Face ID authentication")
                })
                .onAppear() {
                    isFaceIDEnabled = settingsViewModel.isFaceIDEnabled
                }
                .onChange(of: isFaceIDEnabled) {
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
            })
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
    var credentialsViewModel = CredentialsViewModel()
    var authenticationViewModel = AuthenticationViewModel()
    var settingsViewModel = SettingsViewModel(credentialsViewModel: credentialsViewModel, authenticationViewModel: authenticationViewModel)
    
    return SettingsView().environmentObject(settingsViewModel)
}
