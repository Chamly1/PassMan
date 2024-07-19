//
//  AddCredentialView.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 19.07.2024.
//

import SwiftUI

enum Field: Hashable {
    case resource
    case username
    case password
}

struct AddCredentialView: View {
    @EnvironmentObject var credentialsListViewModel: CredentialsListViewModel
    @Environment(\.dismiss) var dismiss
    @State private var inputResource: String = ""
    @State private var inputUsername: String = ""
    @State private var inputPassword: String = ""
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            HStack {
                Spacer()
                Button("Close") {
                    dismiss()
                }.padding([.top, .bottom], 7)
            }
            TextField("Resource name (site, application, etc.)", text: $inputResource)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled(true)
                .focused($focusedField, equals: .resource)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .username
                }
            TextField("Username/Login", text: $inputUsername)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled(true)
                .focused($focusedField, equals: .username)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .password
                }
            SecureField("Password", text: $inputPassword)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .password)
                .submitLabel(.done)
                .onSubmit {
                    focusedField = nil
                }
            Button("Add") {
                credentialsListViewModel.addCredential(resource: inputResource, username: inputUsername, password: inputPassword)
                dismiss()
            }
            .padding([.top, .bottom], 7)
            .buttonStyle(.borderedProminent)
            Spacer()
        }.padding()
    }
}

#Preview {
    AddCredentialView()
}
