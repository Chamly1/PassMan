//
//  AuthenticationViewModel.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 11.08.2024.
//

import Foundation
import CryptoKit

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
    
    private var salt: Data? {
        get {
            return UserDefaults.standard.data(forKey: saltKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: saltKey)
        }
    }
    
    private var sealedBoxVerificationString: Data? {
        get {
            return UserDefaults.standard.data(forKey: sealedBoxVerificationStringKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: sealedBoxVerificationStringKey)
        }
    }
    
    private let hasMasterKeyKey: String = "hasMasterKey"
    private let saltKey: String = "salt"
    private let sealedBoxVerificationStringKey: String = "sealedBoxVerificationString"
    private let saltLength: Int = 16
    private let keyLength: Int = 32
    private let verificationString = "verification"
    
    func initializeMasterKey(password: String) throws {
        // generate salt
        var saltArray = Array<UInt8>(repeating: 0, count: saltLength)
        let status = SecRandomCopyBytes(kSecRandomDefault, saltLength, &saltArray)
        if status != errSecSuccess {
            throw PassManError.saltGenerationError
        }
        
        // derive key
        // TODO: use PBKDF2?
        let inputKeyMaterial = SymmetricKey(data: Data(password.utf8))
        let derivedKey = HKDF<SHA256>.deriveKey(inputKeyMaterial: inputKeyMaterial, salt: saltArray, outputByteCount: keyLength)

        // encrypt verification string
        let verificationData = Data(verificationString.utf8)
        let sealedBox = try ChaChaPoly.seal(verificationData, using: derivedKey)
        
        salt = Data(saltArray)
        sealedBoxVerificationString = sealedBox.combined
        
        isAuthenticated = true
        hasMasterKey = true
    }
    
    func retrieveMasterKey(password: String) throws {
        guard let saltData = salt else {
            throw PassManError.noSalt
        }
        
        let inputKeyMaterial = SymmetricKey(data: Data(password.utf8))
        let derivedKey: SymmetricKey = HKDF<SHA256>.deriveKey(inputKeyMaterial: inputKeyMaterial, salt: saltData, outputByteCount: keyLength)
        
        guard let sealedBoxData = sealedBoxVerificationString else {
            throw PassManError.noSealedBoxVerificationString
        }
        
        // if authentication fail throws an error
        _ = try ChaChaPoly.open(ChaChaPoly.SealedBox(combined: sealedBoxData), using: derivedKey)
        
        isAuthenticated = true
    }
}
