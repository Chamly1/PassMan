import SwiftUI

struct CredentialsListView: View {
    @EnvironmentObject var credentialsListViewModel: CredentialsListViewModel
    @State private var showAddCredentialSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(credentialsListViewModel.credentialsList) { credential in
                    Section {
                        Text(credential.resource)
                        Text(credential.username)
                        Text(credential.password)
                    }
                }
            }
            .listSectionSpacing(.compact)
            .navigationTitle("Credentials")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showAddCredentialSheet = true
                    }, label: {
                        Image(systemName: "plus.circle")
                    }).padding()
                }
            }
            .sheet(isPresented: $showAddCredentialSheet) {
                AddCredentialView()
            }
        }
    }
}

#Preview {
    CredentialsListView().environmentObject(CredentialsListViewModel())
}
