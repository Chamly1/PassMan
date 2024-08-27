//
//  SubsequentAuthenticationView.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 11.08.2024.
//

import SwiftUI
import CryptoKit

struct SubsequentAuthenticationView: View {
    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel
    @EnvironmentObject var credentialsViewModel: CredentialsViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State var inputPassword: String = ""
    @State var showAlert: Bool = false
    @State var activeAlert: ActiveAlert = .general
    @FocusState private var focusedField: FocusedField?
    
    enum ActiveAlert {
        case general
        case incorrectPassword
    }
    
    var body: some View {
        VStack {
            Text("Enter your master password")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
            SecureField("Enter Password", text: $inputPassword)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.done)
            Button("Unlock") {
                do {
                    let key = try authenticationViewModel.retrieveMasterKey(password: inputPassword)
                    if try authenticationViewModel.authenticate(key) {
                        try credentialsViewModel.setEncryptionKey(key: key)
                    } else {
                        activeAlert = .incorrectPassword
                        showAlert = true
                    }
                } catch {
                    activeAlert = .general
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
            case .incorrectPassword:
                Alert(
                    title: Text("Incorrect Password"),
                    message: Text("The password you entered is incorrect. Please try again."),
                    dismissButton: .default(Text("OK")))
            }
        }
        .onAppear() {
            if settingsViewModel.isFaceIDEnabled {
                authenticationViewModel.retrieveMasterKeyWithBiometry() { key in
                    guard let authenticated = try? authenticationViewModel.authenticate(key) else { return}
                    
                    if authenticated {
                        try? credentialsViewModel.setEncryptionKey(key: key)
                    }
                }
            }
        }
    }
}

#Preview {
    SubsequentAuthenticationView()
}
