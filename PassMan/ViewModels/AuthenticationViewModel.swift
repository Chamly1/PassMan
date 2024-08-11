//
//  AuthenticationViewModel.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 11.08.2024.
//

import Foundation

class AuthenticationViewModel: ObservableObject {
    var hasAccount: Bool {
        get {
            return UserDefaults.standard.bool(forKey: hasAccountKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasAccountKey)
        }
    }
    
    private let hasAccountKey: String = "hasAccount"
}
