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
    @EnvironmentObject var credentialsViewModel: CredentialsViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showAddCredentialSheet: Bool = false
    
    @State private var showDeleteConfirmationDialog: Bool = false
    @State private var indexSetToDelete: IndexSet?

    @State private var credentialToEditIndex: ActiveCredential?
    
    var credentialGroupID: UUID
    
    var body: some View {
        guard let credentialGroupIndex: Int = credentialsViewModel.credentialGroups.firstIndex(where: { $0.id == credentialGroupID }) else {
            return AnyView(Text("Credential group not found"))
        }
        
        return AnyView(
            List {
                ForEach(Array($credentialsViewModel.credentialGroups[credentialGroupIndex].credentials.enumerated()), id: \.element.id) { credentialIndex, $credential in
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
                                credentialToEditIndex = ActiveCredential(credentialIndex: credentialIndex)
                            }, label: {
                                Label("Edit", systemImage: "pencil")
                            })
                            Divider()
                            Button(role: .destructive, action: {
                                indexSetToDelete = IndexSet(integer: credentialIndex)
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
                CredentialEditorView(resource: credentialsViewModel.credentialGroups[credentialGroupIndex].resource)
            }
            .sheet(item: $credentialToEditIndex) { item in
                CredentialEditorView(credentialGroupIndex: credentialGroupIndex, 
                                     credentialIndex: item.credentialIndex,
                                     resource: credentialsViewModel.credentialGroups[credentialGroupIndex].resource,
                                     username: credentialsViewModel.credentialGroups[credentialGroupIndex].credentials[item.credentialIndex].username,
                                     password: credentialsViewModel.credentialGroups[credentialGroupIndex].credentials[item.credentialIndex].password)
            }
            .confirmationDialog("asd", isPresented: $showDeleteConfirmationDialog, actions: {
                Button("Delete Credential", role: .destructive) {
                    if let indexes = indexSetToDelete {
                        credentialsViewModel.removeCredentials(credentialGroupIndex: credentialGroupIndex, atOffsets: indexes)
                        if credentialsViewModel.credentialGroups[credentialGroupIndex].credentials.count == 0 {
                            credentialsViewModel.removeCredentialGroups(atOffsets: IndexSet(integer: credentialGroupIndex))
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
        .environmentObject(CredentialsViewModel())
}
