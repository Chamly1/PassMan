//
//  AuthenticationView.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 11.08.2024.
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    
    var body: some View {
        if authenticationViewModel.hasMasterKey {
            SubsequentAuthenticationView()
        } else {
            FirstAuthenticationView()
        }
    }
}

#Preview {
    AuthenticationView()
}
