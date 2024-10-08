import SwiftUI

struct CredentialGroupListView: View {
    @EnvironmentObject private var credentialsViewModel: CredentialsViewModel
    @State private var showCredentialEditorSheet: Bool = false
    @State private var showDeleteConfirmationDialog: Bool = false
    @State private var indexSetToDelete: IndexSet?
    @State private var activeCredentialGroup: ActiveCredentialGroup?
    
    struct ActiveCredentialGroup: Identifiable {
        var credentialGroupIndex: Int
        var id: Int {
            return credentialGroupIndex
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(credentialsViewModel.credentialGroups.enumerated()), id: \.element.id) { credentialGroupIndex, credentialGroup in
                    NavigationLink(destination: {
                        CredentialListView(credentialGroupIndex: credentialGroupIndex)
                    }, label: {
                        Text(credentialGroup.resource)
                    })
                    .contextMenu {
                        Button(action: {
                            activeCredentialGroup = ActiveCredentialGroup(credentialGroupIndex: credentialGroupIndex)
                        }, label: {
                            Label("Rename", systemImage: "pencil")
                        })
                        Divider()
                        Button(role: .destructive, action: {
                            indexSetToDelete = IndexSet(integer: credentialGroupIndex)
                            showDeleteConfirmationDialog = true
                        }, label: {
                            Label("Delete", systemImage: "trash")
                        })
                    }
                }
                .onDelete { indexes in
                    indexSetToDelete = indexes
                    showDeleteConfirmationDialog = true
                }
            }
            .listSectionSpacing(.compact)
            .navigationTitle("Credentials")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCredentialEditorSheet = true
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    ToolbarMenu(sortOption: $credentialsViewModel.groupsSortOption, sortOrder: $credentialsViewModel.groupsSortOrder)
                }
            }
            .sheet(isPresented: $showCredentialEditorSheet) {
                CredentialEditorView(viewModel: CredentialEditorViewModel())
            }
            .sheet(item: $activeCredentialGroup) { item in
                CredentialGroupRenameView(credentialGroupRenameIndex: item.credentialGroupIndex)
            }
            .confirmationDialog("Are you sure you want to delete this credential?", isPresented: $showDeleteConfirmationDialog, actions: {
                Button("Delete Section", role: .destructive) {
                    if let indexes = indexSetToDelete {
                        credentialsViewModel.removeCredentialGroups(atOffsets: indexes)
                    }
                }
                Button("Cancel", role: .cancel, action: {})
            }, message: {
                Text("Deleting this section will remove it and all its content from your device. You can't undo this action.")
            })
        }
    }
}

#Preview {
    CredentialGroupListView().environmentObject(CredentialsViewModel.preview)
}
