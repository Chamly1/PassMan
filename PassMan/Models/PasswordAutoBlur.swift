//
//  AutoBlurOptions.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 13.09.2024.
//

import Foundation

enum PasswordAutoBlur: String, CaseIterable, Identifiable {
    case twoSeconds = "2 seconds"
    case fiveSeconds = "5 seconds"
    case tenSeconds = "10 seconds"
    case fifteenSeconds = "15 seconds"
    case thirtySeconds = "30 seconds"
    case oneMinute = "1 minute"
    case threeMinute = "3 minutes"
    case fiveMinute = "5 minutes"
    case never = "Never"
    
    var id: String { self.rawValue }
    
    var timeInterval: Double {
        switch self {
        case .twoSeconds:
            2
        case .fiveSeconds:
            5
        case .tenSeconds:
            10
        case .fifteenSeconds:
            15
        case .thirtySeconds:
            10
        case .oneMinute:
            60
        case .threeMinute:
            180
        case .fiveMinute:
            300
        case .never:
            0
        }
    }
}
