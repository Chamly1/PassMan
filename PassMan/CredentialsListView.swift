import SwiftUI

struct CredentialsListView: View {
    @EnvironmentObject var credentialsListViewModel: CredentialsListViewModel
    @State private var showAddCredentialSheet: Bool = false
    
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
