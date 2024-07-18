import SwiftUI

struct CredentialsListView: View {
    @EnvironmentObject var credentialsListViewModel: CredentialsListViewModel
    
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
            .navigationTitle("Credentials")
            .listSectionSpacing(.compact)
        }
    }
}

#Preview {
    CredentialsListView().environmentObject(CredentialsListViewModel())
}
