//
//  AuthenticationViewModel.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 11.08.2024.
//

import Foundation
import CryptoKit
import LocalAuthentication

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
    private let symmetrycKeyKeychainkey: String = "symmetrycKeyKeychainkey"
    private let saltLength: Int = 16
    private let keyLength: Int = 32
    private let verificationString = "verification"
    
    func initializeMasterKey(password: String) throws -> SymmetricKey {
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
        return derivedKey
    }
    
    func retrieveMasterKey(password: String) throws -> SymmetricKey {
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
        return derivedKey
    }
    
    /// Saves a symmetric key to the keychain with biometric authentication.
    func saveMasterKeyWithBiometry(_ key: SymmetricKey) throws {
        let keyData = key.withUnsafeBytes { Data(Array($0)) }
        guard let accessControl = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
            .biometryCurrentSet,
            nil
        ) else {
            throw PassManError.keySavingInKeychainError
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: symmetrycKeyKeychainkey,
            kSecValueData as String: keyData,
            kSecAttrAccessControl as String: accessControl
        ]
        
        SecItemDelete(query as CFDictionary) // Delete any existing item
        guard SecItemAdd(query as CFDictionary, nil) == errSecSuccess else {
            throw PassManError.keySavingInKeychainError
        }
    }
    
    /// Reads a symmetric key from the keychain with biometry athentication.
    ///
    /// - Parameter completion: A closure that is called with the retrieved `SymmetricKey` when the key
    ///   is successfully retrieved from the keychain. The completion handler is only executed
    ///   if the key is successfully retrieved and converted.
    func retrieveMasterKeyWithBiometry(completion: @escaping (SymmetricKey) -> Void) {
        let context = LAContext()
        context.localizedReason = "Need for authentication purposes."
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: symmetrycKeyKeychainkey,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecUseAuthenticationContext as String: context
        ]
        
        DispatchQueue.global(qos: .userInitiated).async {
            var dataTypeRef: AnyObject? = nil
            let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
            
            // UI updates and completion handlers should be executed on the main thread to avoid any concurrency issues.
            DispatchQueue.main.async {
                if status == errSecSuccess {
                    if let data = dataTypeRef as? Data {
                        let key = SymmetricKey(data: data)
                        completion(key)
                        self.isAuthenticated = true
                    }
                }
            }
        }
    }
}
