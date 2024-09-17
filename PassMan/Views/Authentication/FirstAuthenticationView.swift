//
//  FirstAuthenticationView.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 11.08.2024.
//

import SwiftUI
import CryptoKit

struct FirstAuthenticationView: View {
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    @EnvironmentObject private var credentialsViewModel: CredentialsViewModel
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @State private var inputPassword: String = ""
    @State private var inputConfirmingPassword: String = ""
    @State private var isFaceIDEnabled: Bool = false
    @State private var showAlert: Bool = false
    @State private var activeAlert: ActiveAlert = .general
    @FocusState private var focusedField: FocusedField?
    
    enum ActiveAlert {
        case general
        case passwordsDoNotMatch
    }
    
    // TODO: add password strength indicator
    var body: some View {
        VStack {
            HStack {
                Text("Create your master password")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                InfoButton(info: "This password will protect all your credentials. Make sure it's something strong and you remembered it.")
            }
            .padding()
            SecureField("Enter Password", text: $inputPassword)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .password)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .confirmPassword
                }
            SecureField("Confirm Password", text: $inputConfirmingPassword)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .confirmPassword)
                .submitLabel(.done)
                .onSubmit {
                    focusedField = nil
                }
            Toggle(isOn: $isFaceIDEnabled) {
                Text("Enable Face ID authentication")
            }.toggleStyle(CheckboxToggleStyle())
            Button("Confirm") {
                if inputPassword == inputConfirmingPassword {
                    do {
                        let key = try authenticationViewModel.initializeMasterKey(password: inputPassword)
                        try credentialsViewModel.setEncryptionKey(key: key)
                        if isFaceIDEnabled {
                            try settingsViewModel.enableFaceID()
                        }
                    } catch {
                        activeAlert = .general
                        showAlert = true
                    }
                } else {
                    activeAlert = .passwordsDoNotMatch
                    showAlert = true
                }
            }
            .padding()
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .alert(isPresented: $showAlert) {
            switch activeAlert {
            case .general:
                generalAlert()
            case .passwordsDoNotMatch:
                Alert(
                    title: Text("Passwords Do Not Match"),
                    message: Text("The password and confirmation do not match. Please re-enter your passwords."),
                    dismissButton: .default(Text("OK")))
            }
        }
    }
}

#Preview {
    FirstAuthenticationView()
}
