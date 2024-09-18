//
//  DetailCredentionalView.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 24.07.2024.
//

import SwiftUI

struct ActiveCredential: Identifiable {
    var credentialIndex: Int
    var id: Int {
        return credentialIndex
    }
}

struct CredentialListView: View {
    var credentialGroupIndex: Int
    
    @EnvironmentObject private var credentialsViewModel: CredentialsViewModel
    @StateObject private var viewModel = CredentialListViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showAddCredentialSheet: Bool = false
    @State private var credentialToEditIndex: ActiveCredential?
    
    var body: some View {
        
        if credentialsViewModel.validateIndex(credentialGroupIndex: credentialGroupIndex) {
            List {
                ForEach(Array($credentialsViewModel.credentialGroups[credentialGroupIndex].credentials.enumerated()), id: \.element.id) { credentialIndex, $credential in
                    CredentialRow(credential: $credential, onEdit: {
                        credentialToEditIndex = ActiveCredential(credentialIndex: credentialIndex)
                    }, onDelete: {
                        viewModel.prepareDeleteAndShowConfirmation(credentialsViewModel: credentialsViewModel, credentialGroupIndex: credentialGroupIndex, atOffsets: IndexSet(integer: credentialIndex))
                    })
                }
                .onDelete { indexes in
                    viewModel.prepareDeleteAndShowConfirmation(credentialsViewModel: credentialsViewModel, credentialGroupIndex: credentialGroupIndex, atOffsets: indexes)
                }
            }
            .navigationTitle(credentialsViewModel.credentialGroups[credentialGroupIndex].resource)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddCredentialSheet = true
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    ToolbarMenu(sortOption: $credentialsViewModel.credentialsSortOption, sortOrder: $credentialsViewModel.credentialsSortOrder)
                }
            }
            .sheet(isPresented: $showAddCredentialSheet) {
                CredentialEditorView(viewModel: CredentialEditorViewModel(resource: credentialsViewModel.credentialGroups[credentialGroupIndex].resource))
            }
            .sheet(item: $credentialToEditIndex) { item in
                CredentialEditorView(viewModel: CredentialEditorViewModel(credentialGroupIndex: credentialGroupIndex,
                                     credentialIndex: item.credentialIndex,
                                     resource: credentialsViewModel.credentialGroups[credentialGroupIndex].resource,
                                     username: credentialsViewModel.credentialGroups[credentialGroupIndex].credentials[item.credentialIndex].username,
                                     password: credentialsViewModel.credentialGroups[credentialGroupIndex].credentials[item.credentialIndex].password))
            }
            .confirmationDialog("Are you sure you want to delete this credential?", isPresented: $viewModel.isDeleteConfirmationShown, actions: {
                Button("Delete Credential", role: .destructive) {
                    viewModel.performDelete(dismiss: { dismiss() })
                }
                Button("Cancel", role: .cancel, action: {})
            }, message: {
                Text("Deleting this credential will remove it from your device. You can't undo this action.")
            })
        } else {
            Text("Credential group not found")
        }
    }
}

#Preview {
    CredentialListView(credentialGroupIndex: 0)
        .environmentObject(CredentialsViewModel.preview)
}
