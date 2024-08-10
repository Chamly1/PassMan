//
//  DetailCredentionalView.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 24.07.2024.
//

import SwiftUI

struct CredentialListView: View {
    @EnvironmentObject var credentialsListViewModel: CredentialsListViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showCredentialEditorSheet: Bool = false
    
    @State private var showDeleteConfirmationDialog: Bool = false
    @State private var indexSetToDelete: IndexSet?

    @State private var credentialToEdit: CredentialWrapper?
    
    var credentialGroupID: UUID
    
    var body: some View {
        guard let credentialGroupIndex: Int = credentialsListViewModel.credentialGroups.firstIndex(where: { $0.id == credentialGroupID }) else {
            return AnyView(Text("Credential group not found"))
        }
        
        return AnyView(
            List {
                ForEach($credentialsListViewModel.credentialGroups[credentialGroupIndex].credentials) { $credential in
                    Section {
                        VStack(alignment: .leading) {
                            Text(credential.username)
                            Divider()
                            // TODO: move isPasswordVisible to the State field and convert CredentialGroupWrapper and CredentialWrapper to classes
                            Text(credential.isPasswordVisible ? credential.password : "************")
                                .blur(radius: credential.isPasswordVisible ? 0 : 6)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        credential.isPasswordVisible.toggle()
                                    }
                                }
                        }
                        .contextMenu {
                            Button(action: {
                                UIPasteboard.general.string = credential.username
                            }, label: {
                                Label("Copy login", systemImage: "doc.on.doc")
                            })
                            Button(action: {
                                UIPasteboard.general.string = credential.password
                            }, label: {
                                Label("Copy password", systemImage: "doc.on.doc")
                            })
                            Button(action: {
                                credentialToEdit = credential
                            }, label: {
                                Label("Edit", systemImage: "pencil")
                            })
                            Divider()
                            Button(role: .destructive, action: {
                                indexSetToDelete = IndexSet(integer: credentialsListViewModel.credentialGroups[credentialGroupIndex].credentials.firstIndex(where: { $0.id == credential.id })!)
                                showDeleteConfirmationDialog = true
                            }, label: {
                                Label("Delete", systemImage: "trash")
                            })
                        }
                    }
                    .listSectionSpacing(.compact)
                }
                .onDelete { indexes in
                    indexSetToDelete = indexes
                    showDeleteConfirmationDialog = true
                }
            }
            .navigationTitle(credentialsListViewModel.credentialGroups[credentialGroupIndex].resource)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCredentialEditorSheet = true
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    ToolbarMenu(sortOption: $credentialsListViewModel.credentialsSortOption, sortOrder: $credentialsListViewModel.credentialsSortOrder)
                }
            }
            .sheet(isPresented: $showCredentialEditorSheet) {
                CredentialEditorView(resourceName: credentialsListViewModel.credentialGroups[credentialGroupIndex].resource)
            }
            .sheet(item: $credentialToEdit) { credential in
                CredentialEditorView(resourceName: credentialsListViewModel.credentialGroups[credentialGroupIndex].resource, credential: credential)
            }
            .confirmationDialog("asd", isPresented: $showDeleteConfirmationDialog, actions: {
                Button("Delete Credential", role: .destructive) {
                    if let indexes = indexSetToDelete {
                        credentialsListViewModel.removeCredentials(credentialGroupIndex: credentialGroupIndex, atOffsets: indexes)
                        if credentialsListViewModel.credentialGroups[credentialGroupIndex].credentials.count == 0 {
                            credentialsListViewModel.removeCredentialGroups(atOffsets: IndexSet(integer: credentialGroupIndex))
                            dismiss()
                        }
                    }
                    
                }
                Button("Cancel", role: .cancel, action: {})
            }, message: {
                Text("Deleting this credential will remove it from your device. You can't undo this action.")
            })
        )
    }
}

#Preview {
    CredentialListView(credentialGroupID: UUID())
        .environmentObject(CredentialsListViewModel())
}
