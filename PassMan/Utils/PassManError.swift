//
//  PassManError.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 13.08.2024.
//

import Foundation

enum PassManError: Error {
    case saltGenerationError
    case noSalt
    case noSealedBoxVerificationString
    case conversionDataToStringError
    case noKey
    case keySavingInKeychainError
    case keyDeletionFromKeychainError
}
