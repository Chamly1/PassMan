//
//  AuthenticationView.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 11.08.2024.
//

import SwiftUI

struct AuthenticationView: View {
    @State var inputPassword: String = ""
    @State var inputConfirmingPassword: String = ""
    @FocusState private var focusedField: FocusedField?
    
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
                
            }
            .padding()
            .buttonStyle(.borderedProminent)
        }.padding()
    }
}

#Preview {
    AuthenticationView()
}
