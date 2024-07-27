import Foundation

struct Credential: Identifiable {
    let id = UUID()
    var username: String
    var password: String
    var isPasswordVisible: Bool = false
}

struct CredentialGroup: Identifiable {
    let id = UUID()
    let resource: String
    var credentials: [Credential]
}

class CredentialsListViewModel: ObservableObject {
    @Published var credentialsList: [CredentialGroup]
    
    init() {
        // stub list
        credentialsList = []
        for i in 0...20 {
            credentialsList.append(CredentialGroup(resource: "resource\(i)", credentials: [Credential(username: "username\(i)", password: "password\(i)"), Credential(username: "username\(i + 1)", password: "password\(i + 1)")]))
        }
    }
    
    //TODO rename to addCredential()
    func addCredentialGroup(resource: String, username: String, password: String) {
        let credential = Credential(username: username, password: password)
        // if such resource already exist - add to it
        for index in credentialsList.indices {
            if credentialsList[index].resource == resource {
                credentialsList[index].credentials.append(credential)
                return
            }
        }
        let credentialGroup = CredentialGroup(resource: resource, credentials: [credential])
        credentialsList.append(credentialGroup)
    }
    
    func editCredential(resource: String, credential: Credential) {
        if let credentialGroupIndex = credentialsList.firstIndex(where: { $0.resource == resource }) {
            if let credentialIndex = credentialsList[credentialGroupIndex].credentials.firstIndex(where: { $0.id == credential.id }) {
                credentialsList[credentialGroupIndex].credentials[credentialIndex] = credential
            }
        }
    }
}
