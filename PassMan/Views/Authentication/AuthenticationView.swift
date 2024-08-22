//
//  AuthenticationView.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 11.08.2024.
//

import SwiftUI

struct AuthenticationView: View {
    @StateObject private var authenticationViewModel = AuthenticationViewModel()
    
    var body: some View {
        if authenticationViewModel.hasMasterKey {
            SubsequentAuthenticationView()
                .environmentObject(authenticationViewModel)
        } else {
            FirstAuthenticationView()
                .environmentObject(authenticationViewModel)
        }
    }
}

#Preview {
    AuthenticationView()
}
