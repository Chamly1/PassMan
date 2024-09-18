//
//  UserDefaultEnum.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 06.08.2024.
//

import Foundation

@propertyWrapper
struct UserDefaultEnum<Value: RawRepresentable> where Value.RawValue == String {
    let key: String
    let defaultValue: Value
    
    var wrappedValue: Value {
        get {
            guard let valueStr = UserDefaults.standard.string(forKey: key), let value = Value(rawValue: valueStr) else {
                return defaultValue
            }
            return value
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
        }
    }
}
