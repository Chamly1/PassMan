//
//  CredentialGroupRenameView.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 13.09.2024.
//

import SwiftUI

struct CredentialGroupRenameView: View {
    var credentialGroupRenameIndex: Int
    
    @EnvironmentObject private var credentialsViewModel: CredentialsViewModel
    @State private var inputResource: String = ""
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert: Bool = false
    
    var body: some View {
        if credentialsViewModel.validateIndex(credentialGroupIndex: credentialGroupRenameIndex) {
            // main view
            VStack(alignment: .trailing, spacing: 10) {
                editorHeaderView
                TextField("Resource name (site, application, etc.)", text: $inputResource)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled(true)
                    .submitLabel(.done)
                Spacer()
            }
            .padding()
            .onAppear {
                inputResource = credentialsViewModel.credentialGroups[credentialGroupRenameIndex].resource
            }
            .alert(isPresented: $showAlert) {
                generalAlert()
            }
        } else {
            // wrong credential group index view
            VStack(spacing: 10) {
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    Spacer()
                }
                Text("No such resource!")
                Spacer()
            }
        }
    }
    
    private var editorHeaderView: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            Spacer()
            Text("Rename Resource")
            Spacer()
            Button("Save") {
                do {
                    try credentialsViewModel.renameCredentialGroup(credentialGroupIndex: credentialGroupRenameIndex, resource: inputResource.isEmpty ? "-" : inputResource)
                    dismiss()
                } catch {
                    showAlert = true
                }
            }
        }.padding([.top, .bottom], 7)
    }
}

#Preview {
    CredentialGroupRenameView(credentialGroupRenameIndex: 0)
        .environmentObject(CredentialsViewModel.preview)
}
