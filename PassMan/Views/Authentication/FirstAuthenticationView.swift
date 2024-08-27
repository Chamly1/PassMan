//
//  FirstAuthenticationView.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 11.08.2024.
//

import SwiftUI
import CryptoKit

struct FirstAuthenticationView: View {
    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel
    @EnvironmentObject var credentialsViewModel: CredentialsViewModel
    @State var inputPassword: String = ""
    @State var inputConfirmingPassword: String = ""
    @State var showAlert: Bool = false
    @State var activeAlert: ActiveAlert = .general
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
            Button("Confirm") {
                if inputPassword == inputConfirmingPassword {
                    do {
                        let key = try authenticationViewModel.initializeMasterKey(password: inputPassword)
                        
                        // TODO: add biometry authentication checkbox
                        
                        try credentialsViewModel.setEncryptionKey(key: key)
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
