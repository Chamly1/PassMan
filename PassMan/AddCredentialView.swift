//
//  AddCredentialView.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 19.07.2024.
//

import SwiftUI

struct AddCredentialView: View {
    @EnvironmentObject var credentialsListViewModel: CredentialsListViewModel
    @Environment(\.dismiss) var dismiss
    @State private var inputResource: String = ""
    @State private var inputUsername: String = ""
    @State private var inputPassword: String = ""
    
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
            TextField("Username/Login", text: $inputUsername)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled(true)
            SecureField("Password", text: $inputPassword)
                .textFieldStyle(.roundedBorder)
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
