//
//  ContentView.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 12.08.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var credentialsViewModel = CredentialsViewModel()
    
    var body: some View {        
        ZStack {
            if credentialsViewModel.isEncryptionKeySet {
                CredentialGroupListView()
                    .transition(.move(edge: .trailing))
                    .environmentObject(credentialsViewModel)
            } else {
                AuthenticationView()
                    .environmentObject(credentialsViewModel)
            }
        }.animation(.default, value: credentialsViewModel.isEncryptionKeySet)
    }
}

#Preview {
    ContentView()
}
