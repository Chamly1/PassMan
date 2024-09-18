//
//  AddCredentialView.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 19.07.2024.
//

import SwiftUI

struct CredentialEditorView: View {
    @StateObject var viewModel: CredentialEditorViewModel
    
    @EnvironmentObject private var credentialsViewModel: CredentialsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert: Bool = false
    @State private var activeAlert: CredentialEditorViewModel.ActiveAlert = .general
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            editorHeaderView
            CredentialInputFields(resource: $viewModel.inputResource,
                                  username: $viewModel.inputUsername,
                                  password: $viewModel.inputPassword,
                                  isPasswordVisible: $viewModel.isPasswordVisible,
                                  focusedField: _focusedField,
                                  showResourceTextField: viewModel.showResourceTextField)
            .onChange(of: viewModel.inputPassword) {
                viewModel.calculatePasswordStrength()
            }
            passwordStrengthView
            HStack{
                Button("Generate password") {
                    viewModel.generatePassword()
                }
                .padding([.top, .bottom], 7)
                .buttonStyle(.borderedProminent)
                Spacer()
            }
            Spacer()
        }
        .padding()
        .alert(isPresented: $showAlert) {
            switch activeAlert {
            case .general:
                generalAlert()
            case .emptyPassword:
                viewModel.generateEmptyPasswordAlert(focusPasswordField: { focusedField = .password }, dismiss: { dismiss() })
            }
        }
    }
    
    private var editorHeaderView: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            Spacer()
            Text(viewModel.titleText)
            Spacer()
            Button("Save") {
                if viewModel.inputPassword.isEmpty {
                    activeAlert = .emptyPassword
                    showAlert = true
                } else {
                    do {
                        try viewModel.saveCredential(credentialsViewModel: credentialsViewModel)
                        dismiss()
                    } catch {
                        activeAlert = .general
                        showAlert = true
                    }
                }
            }
        }.padding([.top, .bottom], 7)
    }
    
    private var passwordStrengthView: some View {
        VStack(alignment: .leading) {
            HStack{
                Text(viewModel.passwordStrengthText)
                    .font(.caption)
                Spacer()
            }
            HStack(spacing: 4) {
                ForEach(0..<PasswordUtility.entropyThreasholds.count, id: \.self) { index in
                    Capsule()
                        .fill(viewModel.passwordStrengthColorLevel >= index ? PasswordUtility.entropyThreasholds[index].2 : .gray)
                        .frame(height: 10)
                }
            }
        }
    }
}

#Preview {
    CredentialEditorView(viewModel: CredentialEditorViewModel())
        .environmentObject(CredentialsViewModel())
}
