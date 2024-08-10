import SwiftUI

struct CredentialGroupListView: View {
    @EnvironmentObject var credentialsListViewModel: CredentialsListViewModel
    @State private var showCredentialEditorSheet: Bool = false
    @State private var showDeleteConfirmationDialog: Bool = false
    @State private var indexSetToDelete: IndexSet?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(credentialsListViewModel.credentialGroups) { credentialGroup in
                    NavigationLink(destination: {
                        DetailCredentialView(credentialGroupID: credentialGroup.id)
                    }, label: {
                        Text(credentialGroup.resource)
                    })
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
                    ToolbarMenu(sortOption: $credentialsListViewModel.groupsSortOption, sortOrder: $credentialsListViewModel.groupsSortOrder)
                }
            }
            .sheet(isPresented: $showCredentialEditorSheet) {
                CredentialEditorView()
            }
            .confirmationDialog("asd", isPresented: $showDeleteConfirmationDialog, actions: {
                Button("Delete Section", role: .destructive) {
                    if let indexes = indexSetToDelete {
                        credentialsListViewModel.removeCredentialGroups(atOffsets: indexes)
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
    CredentialGroupListView().environmentObject(CredentialsListViewModel())
}
