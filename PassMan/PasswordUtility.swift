//
//  PasswordUtility.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 22.07.2024.
//

import Foundation

enum PasswordEntropyError: Error {
    case unexpectedSymbolOccurred
}

struct PasswordUtility {
    private static let passwordLength: Int = 14
    private static let characterPools: [String] = [
        // Lowercase Letters
        "abcdefghijklmnopqrstuvwxyz",
        // Uppercase Letters
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
        // Numbers
        "0123456789",
        // Shift + [0-9] Symbols
        "!@#$%^&*()",
        // Other Symbols
        "`~-_=+[{]}\\|;:'\",<.>/? "
    ]
    
    private static func containsCharactersFromPools(_ password: String) throws -> [Bool] {
        var isContainCharacterFromPool: [Bool] = Array(repeating: false, count: characterPools.count)

        for character in password {
            var isCharacterFromPools: Bool = false
            
            for i in 0..<characterPools.count {
                if characterPools[i].contains(character) {
                    isCharacterFromPools = true
                    isContainCharacterFromPool[i] = true
                    continue
                }
            }
            
            if !isCharacterFromPools {
                throw PasswordEntropyError.unexpectedSymbolOccurred
            }
        }
        
        return isContainCharacterFromPool
    }
    
    static func generatePassword() -> String {
        var resultPassword: String
        var isContainCharacterFromPool: [Bool]
        var isPasswordAppropriate: Bool
        repeat {
            resultPassword = ""
            
            for _ in 0..<passwordLength {
                let poolNum = Int.random(in: 0..<characterPools.count)
                let symbolNum = Int.random(in: 0..<characterPools[poolNum].count)
                let symbolIndex = characterPools[poolNum].index(characterPools[poolNum].startIndex, offsetBy: symbolNum)
                
                resultPassword.append(characterPools[poolNum][symbolIndex])
            }
            
            isContainCharacterFromPool = try! containsCharactersFromPools(resultPassword)
            isPasswordAppropriate = true
            for isContain in isContainCharacterFromPool {
                if !isContain {
                    isPasswordAppropriate = false
                    break
                }
            }
        } while !isPasswordAppropriate
        
        return resultPassword
    }
}
