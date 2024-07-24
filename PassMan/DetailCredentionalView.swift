//
//  DetailCredentionalView.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 24.07.2024.
//

import SwiftUI

struct DetailCredentionalView: View {
    @Binding var credentialGroup: CredentialGroup
    @State private var showAddCredentialSheet: Bool = false
    @State private var showDeleteConfirmationDialog: Bool = false
    @State private var indexSetToDelete: IndexSet?
    
    var body: some View {
        List {
            ForEach($credentialGroup.credentials) { $credential in
                Section {
                    VStack(alignment: .leading) {
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
                .listSectionSpacing(.compact)
            }
            .onDelete { indexes in
                indexSetToDelete = indexes
                showDeleteConfirmationDialog = true
            }
        }
        .navigationTitle(credentialGroup.resource)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showAddCredentialSheet = true
                }, label: {
                    Image(systemName: "plus")
                })
            }
        }
        .sheet(isPresented: $showAddCredentialSheet) {
            AddCredentialGroupView(resourceName: credentialGroup.resource)
        }
        .confirmationDialog("asd", isPresented: $showDeleteConfirmationDialog, actions: {
            Button("Delete Credential", role: .destructive) {
                if let indexes = indexSetToDelete {
                    credentialGroup.credentials.remove(atOffsets: indexes)
                }
                
            }
            Button("Cancel", role: .cancel, action: {})
        }, message: {
            Text("Deleting this credential will remove it from your device. You can't undo this action.")
        })
    }
}

#Preview {
    DetailCredentionalView(credentialGroup: .constant(CredentialGroup(resource: "resource", credentials: [Credential(username: "username1", password: "password1"), Credential(username: "username2", password: "password2")])))
}
