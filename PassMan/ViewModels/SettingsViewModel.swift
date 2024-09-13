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
        get { UserDefaults.standard.bool(forKey: isFaceIDEnabledKey)}
    }
    @Published var appTheme: AppTheme {
        didSet {
            UserDefaults.standard.setValue(appTheme.rawValue, forKey: appThemeKey)
        }
    }
    @AppStorage("isPasswordBlured") var isPasswordBlured: Bool = true
    @Published var passwordAutoBlur: PasswordAutoBlur {
        didSet {
            UserDefaults.standard.setValue(passwordAutoBlur.rawValue, forKey: passwordAutoBlurKey)
        }
    }
    
    private var credentialsViewModel: CredentialsViewModel
    private var authenticationViewModel: AuthenticationViewModel
    private var isFaceIDEnabledKey: String = "isFaceIDEnabled"
    private var appThemeKey: String = "appTheme"
    private var passwordAutoBlurKey: String = "passwordAutoBlur"
    
    init(credentialsViewModel: CredentialsViewModel, authenticationViewModel: AuthenticationViewModel) {
        self.credentialsViewModel = credentialsViewModel
        self.authenticationViewModel = authenticationViewModel
        
        let appThemeRawValue = UserDefaults.standard.string(forKey: appThemeKey) ?? AppTheme.system.rawValue
        appTheme = AppTheme(rawValue: appThemeRawValue) ?? .system
        
        let passwordAutoBlurRawValue = UserDefaults.standard.string(forKey: passwordAutoBlurKey) ?? PasswordAutoBlur.fiveSeconds.rawValue
        passwordAutoBlur = PasswordAutoBlur(rawValue: passwordAutoBlurRawValue) ?? .fiveSeconds
    }
    
    func enableFaceID() throws {
        let key = try credentialsViewModel.getEncryptionKey()
        try authenticationViewModel.saveMasterKeyWithBiometry(key)
        
        UserDefaults.standard.setValue(true, forKey: isFaceIDEnabledKey)
    }
    
    func disableFaceID() throws {
        try authenticationViewModel.deleteMasterKeyWithBiometry()
        
        UserDefaults.standard.setValue(false, forKey: isFaceIDEnabledKey)
    }
}
