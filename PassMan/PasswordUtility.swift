//
//  PasswordUtility.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 22.07.2024.
//

import Foundation

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
    
    static func generatePassword() -> String {
        var resultPassword: String
        var isContainCharacterFromPool: [Bool]
        var isPasswordAppropriate: Bool
        repeat {
            resultPassword = ""
            isContainCharacterFromPool = Array(repeating: false, count: characterPools.count)
            
            for _ in 0..<passwordLength {
                let poolNum = Int.random(in: 0..<characterPools.count)
                let symbolNum = Int.random(in: 0..<characterPools[poolNum].count)
                let symbolIndex = characterPools[poolNum].index(characterPools[poolNum].startIndex, offsetBy: symbolNum)
                
                resultPassword.append(characterPools[poolNum][symbolIndex])
                
                isContainCharacterFromPool[poolNum] = true
            }
            
            isPasswordAppropriate = true
            for isContain in isContainCharacterFromPool {
                if !isContain {
                    isPasswordAppropriate = false
                }
            }
        } while !isPasswordAppropriate
        
        return resultPassword
    }
}
