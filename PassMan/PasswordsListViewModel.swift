import Foundation

class PasswordsListViewModel: ObservableObject {
    @Published var passwordsList: [String]
    
    init() {
        // stub list
        passwordsList = []
        for i in 0...20 {
            passwordsList.append("password\(i)")
        }
    }
}
