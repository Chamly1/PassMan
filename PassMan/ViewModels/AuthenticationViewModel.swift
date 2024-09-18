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
    var hasMasterKey: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasMasterKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.hasMasterKey)
        }
    }
    
    private var salt: Data? {
        get {
            return UserDefaults.standard.data(forKey: UserDefaultsKeys.salt)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.salt)
        }
    }
    
    private var sealedBoxVerificationString: Data? {
        get {
            return UserDefaults.standard.data(forKey: UserDefaultsKeys.sealedBoxVerificationString)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.sealedBoxVerificationString)
        }
    }
    
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
        let verificationStringData = Data(verificationString.utf8)
        let sealedBox = try ChaChaPoly.seal(verificationStringData, using: derivedKey)
        
        salt = Data(saltArray)
        sealedBoxVerificationString = sealedBox.combined
        
        hasMasterKey = true
        return derivedKey
    }
    
    func retrieveMasterKey(password: String) throws -> SymmetricKey {
        guard let saltData = salt else {
            throw PassManError.noSalt
        }
        
        let inputKeyMaterial = SymmetricKey(data: Data(password.utf8))
        let derivedKey: SymmetricKey = HKDF<SHA256>.deriveKey(inputKeyMaterial: inputKeyMaterial, salt: saltData, outputByteCount: keyLength)
        
        return derivedKey
    }
    
    /// Saves a symmetric key to the keychain with biometric authentication.
    func saveMasterKeyWithBiometry(_ masterKey: SymmetricKey) throws {
        let keyData = masterKey.withUnsafeBytes { Data(Array($0)) }
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
                    }
                }
            }
        }
    }
    
    func deleteMasterKeyWithBiometry() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: symmetrycKeyKeychainkey
        ]
        
        guard SecItemDelete(query as CFDictionary) == errSecSuccess else {
            throw PassManError.keyDeletionFromKeychainError
        }
    }
    
    /// - Returns: a Bool value indicating whether the authentication was successful
    func authenticate(_ masterKey: SymmetricKey) throws -> Bool {
        guard let sealedBoxData = sealedBoxVerificationString else {
            throw PassManError.noSealedBoxVerificationString
        }
        
        do {
            _ = try ChaChaPoly.open(ChaChaPoly.SealedBox(combined: sealedBoxData), using: masterKey)
        } catch CryptoKitError.authenticationFailure {
            return false
        }
        
        return true
    }
}
