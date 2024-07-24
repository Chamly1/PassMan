//
//  DetailCredentionalView.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 24.07.2024.
//

import SwiftUI

struct DetailCredentionalView: View {
    @State var credentialGroup: CredentialGroup
    
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
        }
//        .padding()
        .navigationTitle(credentialGroup.resource)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DetailCredentionalView(credentialGroup: CredentialGroup(resource: "resource", credentials: [Credential(username: "username1", password: "password1"), Credential(username: "username2", password: "password2")]))
}
