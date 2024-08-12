//
//  ContentView.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 12.08.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var credentialsViewModel = CredentialsViewModel()
    @StateObject private var authenticationViewModel = AuthenticationViewModel()
    
    var body: some View {        
        ZStack {
            if authenticationViewModel.isAuthenticated {
                CredentialGroupListView()
                    .transition(.move(edge: .trailing))
                    .environmentObject(credentialsViewModel)
            } else {
                AuthenticationView()
                    .environmentObject(authenticationViewModel)
            }
        }.animation(.default, value: authenticationViewModel.isAuthenticated)
    }
}

#Preview {
    ContentView()
}
