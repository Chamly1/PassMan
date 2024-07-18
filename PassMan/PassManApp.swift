import SwiftUI

@main
struct PassManApp: App {
    @StateObject private var passwordsListViewModel = PasswordsListViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(passwordsListViewModel)
        }
    }
}
