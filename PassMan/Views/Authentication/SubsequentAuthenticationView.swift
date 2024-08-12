//
//  SubsequentAuthenticationView.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 11.08.2024.
//

import SwiftUI

struct SubsequentAuthenticationView: View {
    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel
    @State var inputPassword: String = ""
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        VStack {
            Text("Enter your master password")
                .font(.title)
                .multilineTextAlignment(.center)
            SecureField("Enter Password", text: $inputPassword)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.done)
            Button("Unlock") {
                authenticationViewModel.retrieveMasterKey(password: inputPassword)
            }
            .padding()
            .buttonStyle(.borderedProminent)
        }.padding()
    }
}

#Preview {
    SubsequentAuthenticationView()
}
