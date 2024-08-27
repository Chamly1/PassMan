import SwiftUI

@main
struct PassManApp: App {
    @StateObject private var credentialsViewModel: CredentialsViewModel
    @StateObject private var authenticationViewModel: AuthenticationViewModel
    @StateObject private var settingsViewModel: SettingsViewModel
    
    init() {
        let credentialsViewModel = CredentialsViewModel()
        let authenticationViewModel = AuthenticationViewModel()
        _credentialsViewModel = StateObject(wrappedValue: credentialsViewModel)
        _authenticationViewModel = StateObject(wrappedValue: authenticationViewModel)
        _settingsViewModel = StateObject(wrappedValue: SettingsViewModel(credentialsViewModel: credentialsViewModel, authenticationViewModel: authenticationViewModel))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(credentialsViewModel)
                .environmentObject(authenticationViewModel)
                .environmentObject(settingsViewModel)
        }
    }
}
