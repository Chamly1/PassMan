import Foundation

struct Credential: Identifiable {
    let id = UUID()
    let resource: String
    let username: String
    let password: String
}

class CredentialsListViewModel: ObservableObject {
    @Published var credentialsList: [Credential]
    
    init() {
        // stub list
        credentialsList = []
        for i in 0...20 {
            credentialsList.append(Credential(resource: "resource\(i)", username: "username\(i)", password: "password\(i)"))
        }
    }
    
    func addCredential(resource: String, username: String, password: String) {
        let credential = Credential(resource: resource, username: username, password: password)
        credentialsList.append(credential)
    }
}
