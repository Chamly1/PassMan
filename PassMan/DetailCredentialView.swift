//
//  DetailCredentionalView.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 24.07.2024.
//

import SwiftUI

struct DetailCredentialView: View {
    @EnvironmentObject var credentialsListViewModel: CredentialsListViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showAddCredentialSheet: Bool = false
    @State private var showDeleteConfirmationDialog: Bool = false
    @State private var indexSetToDelete: IndexSet?
    
    var credentialGroupIndex: Int
    
    var body: some View {
        List {
            ForEach($credentialsListViewModel.credentialsList[credentialGroupIndex].credentials) { $credential in
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
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = credential.username
                        }, label: {
                            Label("Copy login", systemImage: "doc.on.doc")
                        })
                        Button(action: {
                            UIPasteboard.general.string = credential.password
                        }, label: {
                            Label("Copy password", systemImage: "doc.on.doc")
                        })
                    }
                }
                .listSectionSpacing(.compact)
            }
            .onDelete { indexes in
                indexSetToDelete = indexes
                showDeleteConfirmationDialog = true
            }
        }
        .navigationTitle(credentialsListViewModel.credentialsList[credentialGroupIndex].resource)
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
            AddCredentialGroupView(resourceName: credentialsListViewModel.credentialsList[credentialGroupIndex].resource)
        }
        .confirmationDialog("asd", isPresented: $showDeleteConfirmationDialog, actions: {
            Button("Delete Credential", role: .destructive) {
                if let indexes = indexSetToDelete {
                    credentialsListViewModel.credentialsList[credentialGroupIndex].credentials.remove(atOffsets: indexes)
                    if credentialsListViewModel.credentialsList[credentialGroupIndex].credentials.count == 0 {
                        credentialsListViewModel.credentialsList.remove(at: credentialGroupIndex)
                        dismiss()
                    }
                }
                
            }
            Button("Cancel", role: .cancel, action: {})
        }, message: {
            Text("Deleting this credential will remove it from your device. You can't undo this action.")
        })
    }
}

#Preview {
    DetailCredentialView(credentialGroupIndex: 0)
        .environmentObject(CredentialsListViewModel())
}
