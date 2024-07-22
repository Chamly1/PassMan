import SwiftUI

struct CredentialsListView: View {
    @EnvironmentObject var credentialsListViewModel: CredentialsListViewModel
    @State private var showAddCredentialSheet: Bool = false
    @State private var showDeleteConfirmationDialog: Bool = false
    @State private var indexSetToDelete: IndexSet?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach($credentialsListViewModel.credentialsList) { $credential in
                    Section{
                        VStack(alignment: .leading) {
                            Text(credential.resource)
                            Divider()
                            Text(credential.username)
                            Divider()
                            Text(credential.isPasswordVisible ? credential.password : "************")
                                .blur(radius: credential.isPasswordVisible ? 0 : 6)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        credential.isPasswordVisible.toggle()
                                    }
                                }
                        }
                    }
                }.onDelete { indexes in
                    indexSetToDelete = indexes
                    showDeleteConfirmationDialog = true
                }
            }
            .listSectionSpacing(.compact)
            .navigationTitle("Credentials")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showAddCredentialSheet = true
                    }, label: {
                        Image(systemName: "plus")
                    }).padding()
                }
            }
            .sheet(isPresented: $showAddCredentialSheet) {
                AddCredentialView()
            }
            .confirmationDialog("asd", isPresented: $showDeleteConfirmationDialog, actions: {
                Button("Delete Credential", role: .destructive) {
                    if let indexes = indexSetToDelete {
                        credentialsListViewModel.credentialsList.remove(atOffsets: indexes)
                    }
                    
                }
                Button("Cancel", role: .cancel, action: {})
            }, message: {
                Text("Deleting this credential will remove it from your device. You can't undo this action.")
            })
        }
    }
}

#Preview {
    CredentialsListView().environmentObject(CredentialsListViewModel())
}
