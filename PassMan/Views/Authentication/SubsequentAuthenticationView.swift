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
                    // TODO: Fix issue where an error occurs, but the alert is not displayed because isAuthenticated is set, causing the view to transition before the alert is shown.
                    try credentialsViewModel.setEncryptionKey(key: key)
                } catch CryptoKitError.authenticationFailure {
                    activeAlert = .incorrectPassword
                    showAlert = true
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
            authenticationViewModel.retrieveMasterKeyWithBiometry() { key in
                try? credentialsViewModel.setEncryptionKey(key: key)
            }
        }
    }
}

#Preview {
    SubsequentAuthenticationView()
}
