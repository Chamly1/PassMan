import SwiftUI

@main
struct PassManApp: App {
    @StateObject private var credentialsListViewModel = CredentialsListViewModel()
    
    var body: some Scene {
        WindowGroup {
            CredentialGroupListView()
                .environmentObject(credentialsListViewModel)
        }
    }
}
