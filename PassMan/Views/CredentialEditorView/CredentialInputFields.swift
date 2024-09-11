//
//  CredentialInputFields.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 10.09.2024.
//

import SwiftUI

struct CredentialInputFields: View {
    @Binding var resource: String
    @Binding var username: String
    @Binding var password: String
    @Binding var isPasswordVisible: Bool
    @FocusState var focusedField: FocusedField?
    var showResourceTextField: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            if showResourceTextField {
                TextField("Resource name (site, application, etc.)", text: $resource)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled(true)
                    .focused($focusedField, equals: .resource)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .username
                    }
            }
            
            TextField("Username/Login", text: $username)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled(true)
                .focused($focusedField, equals: .username)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .password
                }
            
            HStack {
                Group {
                    if isPasswordVisible {
                        TextField("Password", text: $password)
                    } else {
                        SecureField("Password", text: $password)
                    }
                }
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .password)
                .submitLabel(.done)
                .onSubmit {
                    focusedField = nil
                }
                
                Button(action: {
                    isPasswordVisible.toggle()
                }, label: {
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                })
            }
        }
    }
}

#Preview {
    @State var resource = "Example Site"
    @State var username = "exampleUser"
    @State var password = "password123"
    @State var isPasswordVisible = false

    return CredentialInputFields(
        resource: $resource,
        username: $username,
        password: $password,
        isPasswordVisible: $isPasswordVisible,
        showResourceTextField: true
    )
}
