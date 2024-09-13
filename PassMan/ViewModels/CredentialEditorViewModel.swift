//
//  CredentialEditorViewModel.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 10.09.2024.
//

import Foundation
import SwiftUI

class CredentialEditorViewModel: ObservableObject {
    @Published var inputResource: String = ""
    @Published var inputUsername: String = ""
    @Published var inputPassword: String = ""
    @Published var isPasswordVisible: Bool = false
    @Published var passwordStrengthText: String = "Password strength: -"
    @Published var passwordStrengthColorLevel = -1
    var showResourceTextField: Bool
    var titleText: String
    var credentialGroupToEditIndex: Int?
    var credentialToEditIndex: Int?
    
    enum CredentialEditorText {
        static let addCredentialTitle = "Add Credential"
        static let editCredentialTitle = "Edit Credential"
    }
    
    enum ActiveAlert {
        case general
        case emptyPassword
    }
    
    init() {
        showResourceTextField = true
        titleText = CredentialEditorText.addCredentialTitle
    }

    /// To add a new credential to the existing resource
    init(resource: String) {
        inputResource = resource
        showResourceTextField = false
        titleText = CredentialEditorText.addCredentialTitle
    }
    
    /// To edit a existing credential
    init(credentialGroupIndex: Int, credentialIndex: Int, resource: String, username: String, password: String) {
        inputResource = resource
        showResourceTextField = false
        titleText = CredentialEditorText.editCredentialTitle
        
        credentialGroupToEditIndex = credentialGroupIndex
        credentialToEditIndex = credentialIndex
        
        self.inputUsername = username
        self.inputPassword = password
        calculatePasswordStrength()
    }
    
    func generatePassword() {
        inputPassword = PasswordUtility.generatePassword()
    }
    
    func saveCredential(credentialsViewModel: CredentialsViewModel) throws {
        if let credentialGroupIndex = credentialGroupToEditIndex, let credentialIndex = credentialToEditIndex, credentialsViewModel.validateIndices(credentialGroupIndex: credentialGroupIndex, credentialIndex: credentialIndex) {
            try credentialsViewModel.editCredential(credentialGroupIndex: credentialGroupIndex, credentialIndex: credentialIndex, username: inputUsername.isEmpty ? "-" : inputUsername, password: inputPassword)
        } else {
            try credentialsViewModel.addCredential(resource: inputResource.isEmpty ? "-" : inputResource, username: inputUsername.isEmpty ? "-" : inputUsername, password: inputPassword)
        }
    }
    
    func calculatePasswordStrength() {
        if inputPassword.isEmpty {
            passwordStrengthText = "Password strength: -"
            passwordStrengthColorLevel = -1
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
            passwordStrengthText = "Password strength: \(PasswordUtility.entropyThreasholds[entropyThreasholdNumber].1)"
            passwordStrengthColorLevel = entropyThreasholdNumber
        } else {
            passwordStrengthText = "Unexpected symbol occure. Can't calculate password strength."
            passwordStrengthColorLevel = -1
        }
    }
    
    func generateEmptyPasswordAlert(focusPasswordField: @escaping () -> Void, dismiss: @escaping () -> Void) -> Alert {
        Alert(
            title: Text("Password Required"),
            message: Text("Please enter your password to continue. Ensure it is typed correctly and try again."),
            primaryButton: .default(Text("Enter Password")) {
                focusPasswordField()
            },
            secondaryButton: .cancel(Text("Dismiss")) {
                dismiss()
            })
    }
}
