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
    @State private var isPasswordVisible: Bool = false
    @State private var isPasswordEmptyAlert: Bool = false
    @FocusState private var focusedField: Field?
    @State private var passworStrengthText: String = "Password strength: -"
    @State private var passworStrengthColoringNum = -1
    
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
            HStack {
                Group {
                    if isPasswordVisible {
                        TextField("Password", text: $inputPassword)
                    } else {
                        SecureField("Password", text: $inputPassword)
                    }
                }
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .password)
                .submitLabel(.done)
                .onSubmit {
                    focusedField = nil
                }
                // Password strength UI update
                .onChange(of: inputPassword) {
                    if inputPassword.isEmpty {
                        passworStrengthText = "Password strength: -"
                        passworStrengthColoringNum = -1
                        return
                    }
                    
                    let passwordEntropy: Float? = try? PasswordUtility.calculatePasswordEntropy(inputPassword)
                    if let entropy = passwordEntropy {
                        var entropyThreasholdNumber = -1
                        for entropyThreashold in PasswordUtility.entropyThreasholds {
                            if entropy >= entropyThreashold.0 {
                                entropyThreasholdNumber += 1
                            } else {
                                break
                            }
                        }
                        passworStrengthText = "Password strength: \(PasswordUtility.entropyThreasholds[entropyThreasholdNumber].1)"
                        passworStrengthColoringNum = entropyThreasholdNumber
                    } else {
                        passworStrengthText = "Unexpected symbol occure. Can't calculate password strength."
                        passworStrengthColoringNum = -1
                    }
                }
                Button(action: {
                    isPasswordVisible.toggle()
                }, label: {
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                })
            }
            HStack{
                Text(passworStrengthText)
                    .font(.caption)
                Spacer()
            }
            HStack(spacing: 4) {
                ForEach(0..<PasswordUtility.entropyThreasholds.count, id: \.self) { index in
                    Capsule()
                        .fill(passworStrengthColoringNum >= index ? PasswordUtility.entropyThreasholds[index].2 : .gray)
                        .frame(height: 10)
                }
            }
            HStack{
                Button("Generate password") {
                    inputPassword = PasswordUtility.generatePassword()
                }
                .padding([.top, .bottom], 7)
                .buttonStyle(.borderedProminent)
                Spacer()
                Button("Save") {
                    if inputPassword.isEmpty {
                        isPasswordEmptyAlert = true
                    } else {
                        credentialsListViewModel.addCredential(resource: inputResource.isEmpty ? "-" : inputResource, username: inputUsername.isEmpty ? "-" : inputUsername, password: inputPassword)
                        dismiss()
                    }
                }
                .padding([.top, .bottom], 7)
                .buttonStyle(.borderedProminent)
            }
            Spacer()
        }
        .padding()
        .alert("Password Required", isPresented: $isPasswordEmptyAlert, actions: {
            Button("Dismiss", role: .cancel, action: {
                dismiss()
            })
            Button("Enter Password", role: .none, action: {
                focusedField = .password
            })
        }, message: {
            Text("Please enter your password to continue. Ensure it is typed correctly and try again.")
        })
    }
}

#Preview {
    AddCredentialView()
}
