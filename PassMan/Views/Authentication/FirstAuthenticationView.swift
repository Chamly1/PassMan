//
//  FirstAuthenticationView.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 11.08.2024.
//

import SwiftUI

struct FirstAuthenticationView: View {
    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel
    @State var inputPassword: String = ""
    @State var inputConfirmingPassword: String = ""
    @State var showAlert: Bool = false
    @FocusState private var focusedField: FocusedField?
    
    // TODO: add password strength indicator
    var body: some View {
        VStack {
            Text("Create your master password")
                .font(.title)
                .multilineTextAlignment(.center)
            Text("This password will protect all your credentials. Make sure it's something strong and you remembered it.").multilineTextAlignment(.center).foregroundColor(.secondary)
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
                    authenticationViewModel.initializeMasterKey(password: inputPassword)
                } else {
                    showAlert = true
                }
            }
            .padding()
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Passwords Do Not Match"),
                message: Text("The password and confirmation do not match. Please re-enter your passwords."),
                dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    FirstAuthenticationView()
}
