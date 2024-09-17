//
//  SettingsViewModel.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 26.08.2024.
//

import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    var isFaceIDEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: UserDefaultsKeys.isFaceIDEnabled)}
    }
    @Published var appTheme: AppTheme {
        didSet {
            UserDefaults.standard.setValue(appTheme.rawValue, forKey: UserDefaultsKeys.appTheme)
        }
    }
    @AppStorage("isPasswordBlured") var isPasswordBlured: Bool = true
    @Published var passwordAutoBlur: PasswordAutoBlur {
        didSet {
            UserDefaults.standard.setValue(passwordAutoBlur.rawValue, forKey: UserDefaultsKeys.passwordAutoBlur)
        }
    }
    
    private var credentialsViewModel: CredentialsViewModel
    private var authenticationViewModel: AuthenticationViewModel
    
    init(credentialsViewModel: CredentialsViewModel, authenticationViewModel: AuthenticationViewModel) {
        self.credentialsViewModel = credentialsViewModel
        self.authenticationViewModel = authenticationViewModel
        
        let appThemeRawValue = UserDefaults.standard.string(forKey: UserDefaultsKeys.appTheme) ?? AppTheme.system.rawValue
        appTheme = AppTheme(rawValue: appThemeRawValue) ?? .system
        
        let passwordAutoBlurRawValue = UserDefaults.standard.string(forKey: UserDefaultsKeys.passwordAutoBlur) ?? PasswordAutoBlur.fiveSeconds.rawValue
        passwordAutoBlur = PasswordAutoBlur(rawValue: passwordAutoBlurRawValue) ?? .fiveSeconds
    }
    
    func enableFaceID() throws {
        let key = try credentialsViewModel.getEncryptionKey()
        try authenticationViewModel.saveMasterKeyWithBiometry(key)
        
        UserDefaults.standard.setValue(true, forKey: UserDefaultsKeys.isFaceIDEnabled)
    }
    
    func disableFaceID() throws {
        try authenticationViewModel.deleteMasterKeyWithBiometry()
        
        UserDefaults.standard.setValue(false, forKey: UserDefaultsKeys.isFaceIDEnabled)
    }
}
