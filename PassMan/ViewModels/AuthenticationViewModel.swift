//
//  AuthenticationViewModel.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 11.08.2024.
//

import Foundation

class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    
    var hasMasterKey: Bool {
        get {
            return UserDefaults.standard.bool(forKey: hasMasterKeyKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasMasterKeyKey)
        }
    }
    
    private let hasMasterKeyKey: String = "hasMasterKey"
    
    func initializeMasterKey(password: String) {
        // TODO: add proper logic
        isAuthenticated = true
        hasMasterKey = true
    }
    
    func retrieveMasterKey(password: String) {
        // TODO: add proper logic
        isAuthenticated = true
    }
}
