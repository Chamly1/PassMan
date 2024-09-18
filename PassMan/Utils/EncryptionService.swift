//
//  EncryptionService.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 20.08.2024.
//

import Foundation
import CryptoKit

class EncryptionService {
    private let key: SymmetricKey
    
    init(key: SymmetricKey) {
        self.key = key
    }
    
    func getKey() -> SymmetricKey {
        return key
    }
    
    func encrypt(_ text: String) throws -> Data {
        return try ChaChaPoly.seal(Data(text.utf8), using: key).combined
    }
    
    func decrypt(_ data: Data) throws -> String {
        let sealedBox = try ChaChaPoly.SealedBox(combined: data)
        let decryptedData = try ChaChaPoly.open(sealedBox, using: key)
        guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
            throw PassManError.conversionDataToStringError
        }
        
        return decryptedString
    }
}
