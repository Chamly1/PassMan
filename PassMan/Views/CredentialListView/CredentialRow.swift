//
//  CredentialRow.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 11.09.2024.
//

import SwiftUI

struct CredentialRow: View {
    @Binding var credential: CredentialWrapper
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
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
                Button(action: {
                    onEdit()
                }, label: {
                    Label("Edit", systemImage: "pencil")
                })
                Divider()
                Button(role: .destructive, action: {
                    onDelete()
                }, label: {
                    Label("Delete", systemImage: "trash")
                })
            }
        }
        .listSectionSpacing(.compact)
    }
}

// TODO: Fix preview
//#Preview {
//    var credential = Credential()
//    var encryptionService = EncryptionService(key: SymmetricKey(size: .bits256))
//    @State var credentialWrapper = try! CredentialWrapper(credential: credential, encryptionService: encryptionService)
//    return CredentialRow(credential: $credentialWrapper, onEdit: {}, onDelete: {})
//}
