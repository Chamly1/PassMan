import SwiftUI

@main
struct PassManApp: App {
    @StateObject private var credentialsViewModel = CredentialsViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(credentialsViewModel)
        }
    }
}
