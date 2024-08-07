import SwiftUI

struct CredentialsListView: View {
    @EnvironmentObject var credentialsListViewModel: CredentialsListViewModel
    @State private var showCredentialEditorSheet: Bool = false
    @State private var showDeleteConfirmationDialog: Bool = false
    @State private var indexSetToDelete: IndexSet?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(credentialsListViewModel.credentialsList) { credentialGroup in
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
                    Menu(content: {
                        Menu(content: {
                            Picker("Sort By", selection: $credentialsListViewModel.groupsSortOption) {
                                ForEach(SortingOptions.allCases) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                            Divider()
                            Picker("Order", selection: $credentialsListViewModel.groupsSortOrder) {
                                ForEach(SortingOrders.allCases) { order in
                                    Text(order.rawValue).tag(order)
                                }
                            }
                        }, label: {
                            Label {
                                // No other working ways to fit two lines in one Menu's label
                                Button(action: {}) {
                                    Text("Sort By")
                                    Text(credentialsListViewModel.groupsSortOption.rawValue)
                                }
                            } icon: {
                                Image(systemName: "arrow.up.arrow.down")
                            }
                        })
                        Button(action: {
                            
                        }, label: {
                            Label("Settings", systemImage: "gear")
                        })
                    }, label: {
                        Image(systemName: "ellipsis")
                    })
                    
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
    CredentialsListView().environmentObject(CredentialsListViewModel())
}
