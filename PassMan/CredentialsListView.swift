import SwiftUI

struct CredentialsListView: View {
    @EnvironmentObject var credentialsListViewModel: CredentialsListViewModel
    @State private var showAddCredentialSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach($credentialsListViewModel.credentialsList) { $credential in
                    Section {
                        Text(credential.resource)
                        Text(credential.username)
                        Text(credential.isPasswordVisible ? credential.password : "stubpassword")
                            .blur(radius: credential.isPasswordVisible ? 0 : 7)
                            .onTapGesture {
                                credential.isPasswordVisible.toggle()
                            }
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
