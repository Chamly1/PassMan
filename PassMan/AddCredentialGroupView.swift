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

struct AddCredentialGroupView: View {
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
    
    private var showResourceTextField: Bool
    private var credentialToEdit: Credential?
    private var titleText: String = "Add Credential"
    
    init() {
        showResourceTextField = true
    }

    /// To add a new credential to the existing resource
    init(resourceName: String) {
        inputResource = resourceName
        showResourceTextField = false
    }
    
    /// To edit a existing credential
    init(resourceName: String, credential: Credential) {
        inputResource = resourceName
        showResourceTextField = false
        titleText = "Edit Credential"
        
        credentialToEdit = credential
        self._inputUsername = State(initialValue: credential.username)
        self._inputPassword = State(initialValue: credential.password)
        
        let passwordStrengthUIValues = getPasswordStrengthUIValues()
        self._passworStrengthText = State(initialValue: passwordStrengthUIValues.0)
        self._passworStrengthColoringNum = State(initialValue: passwordStrengthUIValues.1)
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Text(titleText)
                Spacer()
                Button("Save") {
                    if inputPassword.isEmpty {
                        isPasswordEmptyAlert = true
                    } else {
                        saveCredential()
                        dismiss()
                    }
                }
            }.padding([.top, .bottom], 7)
            if showResourceTextField {
                TextField("Resource name (site, application, etc.)", text: $inputResource)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled(true)
                    .focused($focusedField, equals: .resource)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .username
                    }
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
                    let passwordStrengthUIValues = getPasswordStrengthUIValues()
                    passworStrengthText = passwordStrengthUIValues.0
                    passworStrengthColoringNum = passwordStrengthUIValues.1
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
    
    private func saveCredential() {
        if var credential = credentialToEdit {
            credential.username = inputUsername.isEmpty ? "-" : inputUsername
            credential.password = inputPassword
            credentialsListViewModel.editCredential(resource: inputResource, credential: credential)
        } else {
            credentialsListViewModel.addCredentialGroup(resource: inputResource.isEmpty ? "-" : inputResource, username: inputUsername.isEmpty ? "-" : inputUsername, password: inputPassword)
        }
    }
    
    private func getPasswordStrengthUIValues() -> (String, Int) {
        if inputPassword.isEmpty {
            return ("Password strength: -", -1)
        }
        
        var text: String
        var coloringNum: Int
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
            text = "Password strength: \(PasswordUtility.entropyThreasholds[entropyThreasholdNumber].1)"
            coloringNum = entropyThreasholdNumber
        } else {
            text = "Unexpected symbol occure. Can't calculate password strength."
            coloringNum = -1
        }
        return (text, coloringNum)
    }
}

#Preview {
    AddCredentialGroupView()
}
