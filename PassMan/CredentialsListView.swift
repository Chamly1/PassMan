import SwiftUI

struct CredentialsListView: View {
    @EnvironmentObject var credentialsListViewModel: CredentialsListViewModel
    @State private var showAddCredentialSheet: Bool = false
    @State private var showDeleteConfirmationDialog: Bool = false
    @State private var indexSetToDelete: IndexSet?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(credentialsListViewModel.credentialsList) { credentials in
                    NavigationLink(destination: {
                        DetailCredentionalView(credentialGroup: credentials)
                    }, label: {
                        Text(credentials.resource)
                    })
                }.onDelete { indexes in
                    indexSetToDelete = indexes
                    showDeleteConfirmationDialog = true
                }
            }
            .listSectionSpacing(.compact)
            .navigationTitle("Credentials")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddCredentialSheet = true
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: "gear")
                    })
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: "line.3.horizontal.decrease")
                    })
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: "arrow.up.arrow.down")
                    })
                }
            }
            .sheet(isPresented: $showAddCredentialSheet) {
                AddCredentialGroupView()
            }
            .confirmationDialog("asd", isPresented: $showDeleteConfirmationDialog, actions: {
                Button("Delete Section", role: .destructive) {
                    if let indexes = indexSetToDelete {
                        credentialsListViewModel.credentialsList.remove(atOffsets: indexes)
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
    CredentialsListView().environmentObject(CredentialsListViewModel())
}
